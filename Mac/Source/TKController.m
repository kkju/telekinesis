//
//  TKController.m
//  Telekinesis
//
//  Created by Nicholas Jitkoff on 6/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "TKController.h"
#import "SimpleHTTPConnection.h"
#import "SimpleHTTPServer.h"
#import <stdio.h>
#import <string.h>
#import <sys/socket.h>
#include <arpa/inet.h>
#include <SystemConfiguration/SystemConfiguration.h>
#import "NSURL+Parameters.h"
#import "glgrab.h"

#import "QSKeyCodeTranslator.h"

@interface TKController (PrivateMethods)
- (NSString *)applicationSupportFolder;
- (NSString *)serverRootFolder;
- (NSString *)appsFolder;
- (void) startServices;
- (void) stopServices;
- (void) generateCertificateIfNeeded;
- (void)getPasswordIfNeeded;
- (NSTask *)taskWithDictionary:(NSDictionary *)taskOptions basePath:(NSString *)basePath;
@end


void CatchInterrupt (int signum) {
  pid_t my_pid;
  
  printf("\nReceived an interrupt! About to exit ..\n");
  
  fflush(stdout);
  
  [[NSApp delegate] stopServices];
  my_pid = getpid();
  kill(my_pid, SIGKILL);
}


@implementation TKController
+ (void) initialize {
  signal(SIGTERM, CatchInterrupt);  
  
  NSMutableDictionary *newDefaults = [NSMutableDictionary dictionary];
  [newDefaults addEntriesFromDictionary:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSUserDefaults"]];
  [newDefaults setObject:[NSNumber numberWithBool:NO]
                  forKey:@"headersHidden"];
  [newDefaults setObject:@"./Contents/Resources/style.css"
                  forKey:@"stylePath"];
  
  [[NSUserDefaults standardUserDefaults] registerDefaults:newDefaults];
}

+ (NSArray *) currentIP4Addresses
{
	// http://cocoa.mamasam.com/COCOADEV/2001/11/2/18325.php
  
	NSMutableArray * addresses;
	SCDynamicStoreRef
    dynRef=SCDynamicStoreCreate(kCFAllocatorSystemDefault,
                                (CFStringRef)@"Telekinesis", NULL, NULL);
	// Get all available interfaces IPv4 addresses
	NSArray *interfaceList=(NSArray *)SCDynamicStoreCopyKeyList(dynRef,(CFStringRef)@"State:/Network/Service/..*/IPv4");

NSEnumerator *interfaceEnumerator=[interfaceList objectEnumerator];
addresses = [NSMutableArray arrayWithCapacity:[interfaceList count]];
NSString *interface;

while(interface=[interfaceEnumerator nextObject]) {
		NSDictionary *interfaceEntry=(NSDictionary
                                  *)SCDynamicStoreCopyValue(dynRef,(CFStringRef)interface);
  
		[addresses addObject:interfaceEntry];
		[interfaceEntry release]; // must be released
}

[interfaceList release]; // must be released
return [NSArray arrayWithArray:addresses];
}

- (id) init {
  self = [super init];
  if (self != nil) {
    [self setServer:[[[SimpleHTTPServer alloc] initWithTCPPort:[self telePortNumber]
                                                      delegate:self] autorelease]];
    
    [self applicationSupportFolder];
    
    applications = [[NSMutableArray alloc] init];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    
    NSString *externalAppsPath = [[self applicationSupportFolder] stringByAppendingPathComponent:@"Apps"];
    //    NSString *internalAppsPath = [[[NSBundle mainBundle] pathForResource:@"www" ofType:@""] stringByAppendingPathComponent:@"ipps"];
    
    [fm createDirectoryAtPath:[self applicationSupportFolder] attributes:nil];
    [fm createDirectoryAtPath:externalAppsPath attributes:nil];
    [fm createDirectoryAtPath:[self serverRootFolder] attributes:nil];
    
  }
  return self;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
  NSEnumerator *e = [filenames objectEnumerator];
  NSString *filename;

  NSAlert *alert = [NSAlert alertWithMessageText:@"Install Applications?"
                                   defaultButton:@"Install" 
                                 alternateButton:@"Cancel"
                                     otherButton:nil 
                       informativeTextWithFormat:@"Would you like to install the following applications and restart the Remote? (%@)", 
    
    [[filenames valueForKeyPath:@"lastPathComponent.stringByDeletingPathExtension"] componentsJoinedByString:@", "]]; 
  int installResult = [alert runModal];
  NSLog(@"res %d", installResult);
  if (installResult < 1) return;
  
  while (filename = [e nextObject]) {
    if ([filename hasPrefix:[self appsFolder]]) continue;
    
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *destination = [[self appsFolder] stringByAppendingPathComponent:[filename lastPathComponent]];
    
    if ([fm fileExistsAtPath:destination]) {
      NSAlert *alert = [NSAlert alertWithMessageText:@"Replace this Application?"
                                       defaultButton:@"Replace" alternateButton:@"Skip" otherButton:nil informativeTextWithFormat:@"%@ is already installed. Replace it?", [filename lastPathComponent]]; 
      int result = [alert runModal];
      
      if (result < 1) continue;
        [fm removeFileAtPath:destination handler:nil];
    }
      [fm movePath:filename
            toPath:destination
           handler:nil];
      
      
  }
  [self restartServices:nil];
}



- (void) reloadApps {
  [applications removeAllObjects];
  NSString *externalAppsPath = [[self applicationSupportFolder] stringByAppendingPathComponent:@"Apps"];
  
  NSArray *paths = [[NSFileManager defaultManager] directoryContentsAtPath:externalAppsPath];
  paths = [paths pathsMatchingExtensions:[NSArray arrayWithObject:@"tapp"]];
  NSEnumerator *de = [paths objectEnumerator];
  NSString *path;
  while (path = [de nextObject]) {
    path = [externalAppsPath stringByAppendingPathComponent:path];
    NSString *infoPath = [path stringByAppendingPathComponent:@"Info.plist"];
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithContentsOfFile:infoPath];
    if (!info) info = [NSMutableDictionary dictionary];
    [info setObject:path forKey:@"path"];
    [info setObject:[[path lastPathComponent] stringByDeletingPathExtension] forKey:@"name"];
    if (info) [applications addObject:info];
  }
  NSLog(@"Applications installed: %@", [[applications valueForKey:@"name"] componentsJoinedByString:@","]);
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
  //  [self goHome:nil];
  return NO; 
}


- (IBAction)showPrefs:(id) sender {
  [prefsWindow center];
  [NSApp activateIgnoringOtherApps:YES];
  [prefsWindow makeKeyAndOrderFront:nil];
}


- (BOOL)validateMenuItem:(NSMenuItem *)item {
  if ([item action] == @selector(toggleServices:)) {
    
    [item setTitle:servicesRunning ? @"Stop Remote" : @"Start Remote"];
  }
  return YES;
}

- (void)menuNeedsUpdate:(NSMenu *)menu{
  //  [[menu itemWithTag:2] setTitle:@"ip address"];
}


- (int)userPortForDefault:(NSString *)key{
  int port = [[NSUserDefaults standardUserDefaults] integerForKey:key];
  if (port < 1024) {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    port = [[NSUserDefaults standardUserDefaults] integerForKey:key];
  }
  return port;
}

- (int)portNumber {return [self userPortForDefault:@"port"];}
- (int)telePortNumber {return [self userPortForDefault:@"telePort"];}
- (int)mediaPortNumber {return [self userPortForDefault:@"mediaPort"];}


- (IBAction) goSupport:(id)sender {
  // [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http:// 
}
- (void) goHome:(id)sender {
  NSArray *interfaces = [[self class] currentIP4Addresses];
  NSArray *en1 = [interfaces filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"InterfaceName LIKE 'en1'"]];
  if (en1) interfaces = en1;
  
  NSArray *addresses = [interfaces valueForKeyPath:@"@distinctUnionOfArrays.Addresses"];
  
  NSString *urlString = [NSString stringWithFormat:@"https://%@:%d", ([addresses count] ? [addresses lastObject] : @"localhost"), [self portNumber]];
  [[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:[NSURL URLWithString:urlString]]
                  withAppBundleIdentifier:@"com.apple.Safari"
                                  options:nil additionalEventParamDescriptor:nil launchIdentifiers:nil];
  //
  //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
  //NSLog(@"request %@", urlString);
  //[[webView mainFrame] loadRequest:request];
}
- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  
  // No Status item for now
  // statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:24] retain];
  [statusItem setHighlightMode:YES];
  [statusItem setMenu:statusMenu];
  [statusItem setImage:[NSImage imageNamed:@"TKMenu"]];
  
  [self startServices];  
  if (shouldShowHomepage) [self performSelector:@selector(goHome:) withObject:nil afterDelay:0.4];
  
}
- (void)dealloc
{
  [apacheTask terminate];
  [apacheTask release];
  apacheTask = nil;
  
  [server release];
  [super dealloc];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
  [self stopServices]; 
}


- (IBAction) restartServices:(id)sender {
  [self stopServices];
  [self startServices];
}


- (IBAction) toggleServices:(id)sender {
  if (servicesRunning) {
    [self stopServices];
  } else { 
    [self startServices];
  }
}

- (void) startServices {
  if (servicesRunning) return;
  
  
  
  // Commit port changes, if needed.
  [prefsWindow makeFirstResponder:prefsWindow];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  [self reloadApps];
  [self generateCertificateIfNeeded];
  [self getPasswordIfNeeded];
  
  NSString *root = [[NSBundle mainBundle] resourcePath];
  
  NSString *documentRoot = root;
  
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"useSourceWebDirectory"]) {
    documentRoot =  @"/Volumes/Lux/telekinesis/trunk/Mac/Resources/";
    NSLog(@"using lux root");
  }
  
  BOOL apache2= [[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apache2/"];
  NSString *config = [[NSBundle mainBundle] pathForResource:(apache2 ? @"httpd.2.0" : @"httpd.1.3.33") ofType:@"conf"];
  
  
  NSMutableArray *arguments = [NSMutableArray arrayWithObjects:
    @"-d", [self serverRootFolder],
    @"-f", config,
    nil];
  
  
  NSMutableArray *directives = [NSMutableArray arrayWithObjects:
    [NSString stringWithFormat:@"Alias /resources/ \"%@\"", root],
    [NSString stringWithFormat:@"DocumentRoot \"%@/www/\"", documentRoot],
    [NSString stringWithFormat:@"Alias /Apps/ \"%@/Apps/\"", [self applicationSupportFolder]],
    [NSString stringWithFormat:@"ScriptAlias /cgi/ \"%@/cgi-bin/\"",  documentRoot],
    nil];
  
  NSEnumerator *e = [applications objectEnumerator];
  NSMutableDictionary *info;
  while (info = [e nextObject]) {
    NSString *path = [info objectForKey:@"path"];
    NSDictionary *startTaskOptions =  [info objectForKey:@"startTask"];
    NSTask *task = [self taskWithDictionary:startTaskOptions basePath:path];
    if (task) {
      [info setObject:task forKey:@"task"];
      
      NSLog(@"Starting task for %@", [info objectForKey:@"name"]);
      [task launch];
    }
    
    NSNumber *proxyPort = [info objectForKey:@"proxyPort"];
    if (proxyPort) {
      NSLog(@"ProxyPass \"/apps/%@\" http://localhost:%@", [path lastPathComponent], proxyPort);
      [directives addObject:[NSString stringWithFormat:@"ProxyPass \"/Apps/%@\" http://localhost:%@", [path lastPathComponent], proxyPort]];
      [directives addObject:[NSString stringWithFormat:@"ProxyPassReverse \"/Apps/%@\" http://localhost:%@", [path lastPathComponent], proxyPort]];
    }
  }
  
  
  
  
  NSString *configPath = [[NSBundle mainBundle] pathForResource:@"httpd.telekinesis" ofType:@"conf"];
  NSString *customConfig = [NSString stringWithContentsOfFile:configPath];
  
  customConfig = [NSString stringWithFormat:customConfig, [self portNumber], [self mediaPortNumber], NSHomeDirectory(), [[NSBundle mainBundle] bundlePath], [self applicationSupportFolder]];
  customConfig = [NSString stringWithFormat:customConfig, [self portNumber], [self mediaPortNumber]];
  NSString *customConfigPath = [[self serverRootFolder] stringByAppendingPathComponent:@"custom.conf"];
  
  [customConfig writeToFile:customConfigPath atomically:NO];
  
  //  [directives addObject:[NSString stringWithFormat:@"Include \"%@\"", configPath]];
  
//  NSLog(@"Directives %@", directives);
  NSEnumerator *de = [directives objectEnumerator];
  id item;
  while (item = [de nextObject]) {
    [arguments addObject:@"-c"];
    [arguments addObject:item];
  }
  
  
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"EnableMediaPort"]) {
    NSLog(@"Enabling media port %d", [self mediaPortNumber]);
    [arguments addObject:@"-D"];
    [arguments addObject:@"EnableMediaPort"];
  }
  
  
  NSString *computerName = [(id)SCDynamicStoreCopyComputerName(NULL, NULL) autorelease];
  NSString *rootVolumeName = [[NSFileManager defaultManager] displayNameAtPath:@"/"];
  NSMutableDictionary *environment = [[[[NSProcessInfo processInfo] environment] mutableCopy] autorelease];
  
  [environment setObject:computerName forKey:@"COMPUTER_NAME"];
  [environment setObject:[NSString stringWithFormat:@"%d", [self mediaPortNumber]] forKey:@"MEDIA_PORT"];
  [environment setObject:rootVolumeName forKey:@"ROOT_VOLUME_NAME"];
  apacheTask = [[NSTask alloc] init];
  [apacheTask setLaunchPath:@"/usr/sbin/httpd"];
  [apacheTask setArguments:arguments];
  [apacheTask setEnvironment:environment];
  NSLog(@"Starting server on port %d", [self portNumber]);
  [apacheTask launch];
  
  servicesRunning = YES;
  [statusItem setImage:[NSImage imageNamed:@"TKMenu"]];
}

- (NSTask *)taskWithDictionary:(NSDictionary *)taskOptions basePath:(NSString *)basePath {
  NSString *command = [taskOptions valueForKey:@"path"];
  if (!command) return nil;
  
  if (![command hasPrefix:@"/"]) command = [basePath stringByAppendingPathComponent:command];
  command = [command stringByStandardizingPath];
  
  NSArray *arguments = [taskOptions objectForKey:@"arguments"];
  if (!arguments) arguments = [NSArray array];
  
  NSTask *task = [[[NSTask alloc] init] autorelease];
  [task setLaunchPath:command];
  [task setArguments:arguments];  
  return task;
}

- (void) stopServices {   
  if (!servicesRunning) return;
  
  // Stop application services
  
  NSEnumerator *e = [applications objectEnumerator];
  NSMutableDictionary *info;
  while (info = [e nextObject]) {
    
    NSDictionary *stopTaskOptions =  [info objectForKey:@"stopTask"];
    if (stopTaskOptions) {
      NSTask *task = [self taskWithDictionary:stopTaskOptions basePath:[info objectForKey:@"path"]];
      [task launch];
    } else {
      NSTask *task = [info objectForKey:@"task"];
      
      NSLog(@"Stopping task for %@", [info objectForKey:@"name"]);
      [task terminate];
    }
    
  } 
  
  
  NSString *pidString = [NSString stringWithContentsOfFile:[[[self applicationSupportFolder] stringByAppendingPathComponent:@"Server"] stringByAppendingPathComponent:@"httpd.pid"]];
  pid_t pid = [pidString intValue];
  if (pid) kill(pid,SIGTERM);
  [apacheTask waitUntilExit];
  
  [apacheTask release];
  apacheTask = nil;
  servicesRunning = NO;	
  [statusItem setImage:[NSImage imageNamed:@"TKMenu_disabled"]];
}


- (IBAction)cancelPass:(id)sender{ 
  [NSApp stopModalWithCode:0];
}


- (IBAction)savePass:(id)sender{ 
  if (![[passField stringValue] length]) {
    NSBeep();
    return;
  }
  [NSApp stopModalWithCode:1];
}



- (IBAction)choosePass:(id)sender {
  NSString *passfile = [[self serverRootFolder] stringByAppendingPathComponent:@"authorized-users"];
  [[userField window] center];
  [[userField window] makeKeyAndOrderFront:nil];
  int code = [NSApp runModalForWindow:[userField window]];
  
  
  if (!code) {
    if (![[NSFileManager defaultManager] fileExistsAtPath:passfile]) [NSApp terminate:nil];
    return;
  }
  NSString *user = [userField stringValue];
  NSString *pass = [passField stringValue];
  [[userField window] close];
  shouldShowHomepage = YES;
  
  [[NSTask launchedTaskWithLaunchPath:@"/usr/bin/htpasswd"
                            arguments:[NSArray arrayWithObjects:@"-bc", passfile, user, pass, nil]] waitUntilExit];
  
  // @htpasswd -bc passwords alcor blah  
}

- (void)getPasswordIfNeeded{
  NSString *passfile = [[self serverRootFolder] stringByAppendingPathComponent:@"authorized-users"];
  if ([[NSFileManager defaultManager] fileExistsAtPath:passfile]) return;
  [self choosePass:nil];
}

- (void) generateCertificateIfNeeded {
  NSString *certgen = [[NSBundle mainBundle] pathForResource:@"certificate" ofType:@"sh"];
  NSString *certconfig = [[NSBundle mainBundle] pathForResource:@"certificate" ofType:@"cfg"];
  NSString *outkeyfile = [[self serverRootFolder] stringByAppendingPathComponent:@"certificate.pem"];
  
  
  if ([[NSFileManager defaultManager] fileExistsAtPath:outkeyfile]) return;
  
  
  NSArray *arguments = [NSArray arrayWithObjects:
    certconfig,
    outkeyfile,
    nil];
  
  // openssl req  -config $1 -keyout $2 -newkey rsa:1024 -nodes -x509 -days 365 -out $2
  NSTask *task = [NSTask launchedTaskWithLaunchPath:certgen
                                          arguments:arguments];
  [task waitUntilExit];
}













- (void)setServer:(SimpleHTTPServer *)sv
{
  [server autorelease];
  server = [sv retain];
}

- (SimpleHTTPServer *)server { return server; }


- (void)processTelekinesis:(NSDictionary *)params connection:(SimpleHTTPConnection *)connection {
  
  
}

- (NSString *)serverRootFolder {
  return [[self applicationSupportFolder]stringByAppendingPathComponent:@"Server"];
}
- (NSString *)appsFolder {
  return [[self applicationSupportFolder]stringByAppendingPathComponent:@"Apps"];
}
- (NSString *)applicationSupportFolder {
	NSString *appSupportFolder = [@"~/Library/Application Support/iPhone Remote/" stringByStandardizingPath];
  NSFileManager *manager = [NSFileManager defaultManager];
  
  if( ![manager fileExistsAtPath:appSupportFolder] )
		[manager createDirectoryAtPath:appSupportFolder attributes:nil];	
	
  return appSupportFolder;
  
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
  
  
	basePath = [basePath stringByAppendingPathComponent:@"Cultured Code"];
	if( ![manager fileExistsAtPath:basePath] ) {
		[manager createDirectoryAtPath:basePath attributes:nil];
  }
  
}





// Nasty function that handles most of the advanced functionality

- (void)processURL:(NSURL *)url connection:(SimpleHTTPConnection *)connection {
  
  NSData *data = nil;
  NSString *mime = nil;
  NSString *path = [url path];
  
  if ([path isEqualToString:@"/"]) path = @"/index.html";
#pragma mark Get the screen
  if ([[url path] isEqualToString:@"/screen.png"] || [[url path] hasPrefix: @"/grabscreen"]) {
    NSString *mode = [[url parameterDictionary] objectForKey:@"mode"];
    CGRect rect;
    
    CGDirectDisplayID displayID = CGMainDisplayID();
    if (!mode) {
      
      rect = CGDisplayBounds(displayID);
    } else if ([mode isEqualToString:@"update"]) {
      rect = CGRectMake(100*region,0,100,100);
      
      region = (region + 1) % 4;
    } else if ([mode isEqualToString:@"region"]) {
      rect = CGRectMake(100*region,0,100,100);
    }
    
    CGImageRef theCGImage = grabViaOpenGL(displayID, rect);
    
    NSMutableData* imageData = [NSMutableData data];
    CGImageDestinationRef destCG = CGImageDestinationCreateWithData((CFMutableDataRef)imageData,  kUTTypeJPEG,1,NULL);
    CGImageDestinationAddImage(destCG, theCGImage, NULL);
    CGImageDestinationFinalize(destCG);
    data = imageData;
    mime = @"image/jpeg";
    
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
      mime, @"Content-Type",
      [NSString stringWithFormat:@"name=%d+%d", (int)rect.origin.x, (int)rect.origin.y], @"Set-Cookie",
      nil];
    
    [server replyWithStatusCode:200 headers:headers body:data];  // 200 = 'OK'
    usleep(100000);
    return;
    
    
#pragma mark Run a script
  } else if ([[url path] hasPrefix:@"/runscript"]) {
    NSDictionary *params =  [url parameterDictionary];
    
    NSString *path = [[params objectForKey:@"path"] stringByStandardizingPath];
    
    NSAppleScript *script = nil;
    if (path) {
      path = [path stringByStandardizingPath];
      if (![path hasPrefix:@"/"]) {
        NSString *appName = [params objectForKey:@"app"];
        
        NSString *basePath = nil;
        
        if (appName) {
          NSArray *matches = [applications filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name LIKE %@", appName]];
          if ([matches count]) 
            basePath = [[applications lastObject] objectForKey:@"path"];
        }
        if (!basePath) {
          basePath = [[NSBundle mainBundle] resourcePath];
        }
        path = [basePath stringByAppendingPathComponent:path];
        
      }
      
      NSLog(@"Running script %@", path);
      
      script = [[[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]
                                                       error:nil] autorelease];
    }
    
    
    //  else {
    //    NSString *source = [params objectForKey:@"source"];
    //    if (source) {
    //      script = [[[NSAppleScript alloc] initWithSource:source] autorelease];
    //    }
    //  }
    
    NSAppleEventDescriptor *descriptor = [script executeAndReturnError:nil];
    data = [[descriptor stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    mime = @"text/plain";
    
    if (!data) {
      [server replyWithStatusCode:200 message:@""];
      return;
    }
    
#pragma mark Get an icon
} else if ([[url path] hasPrefix:@"/icon"]) {
  NSDictionary *params =  [url parameterDictionary];
  
  NSString *path = [params objectForKey:@"path"];
  path = [[path componentsSeparatedByString:@"+"] componentsJoinedByString:@" "];
  path = [path stringByStandardizingPath];
  NSSize size = NSSizeFromString([params objectForKey:@"size"]);
  
  NSImage *image = [[NSWorkspace sharedWorkspace] iconForFile:path];
  
  if (!NSEqualSizes(size,NSZeroSize)) [image setSize:size];
  
  data = [(NSBitmapImageRep *)[image bestRepresentationForDevice:nil] representationUsingType:NSPNGFileType properties:nil];
  mime = @"image/png";    
  
#pragma mark click
} else if ([[url path] hasPrefix: @"/click"]) {
  
  NSDictionary *params =  [url parameterDictionary];
  //;hi?31,191
  //NSArray *points = [[url query] componentsSeparatedByString:@","];
  CGPoint p;
  p.x = [[params objectForKey:@"x"] intValue];
  p.y = [[params objectForKey:@"y"] intValue];
  CGWarpMouseCursorPosition(p);
  
  CGPostMouseEvent(p, 0, 1, 1);
  CGPostMouseEvent(p, 0, 1, 0);    
  [server replyWithStatusCode:200 message:@""];
  
  return;
#pragma mark move
} else if ([[url path] hasPrefix: @"/mousemove"]) {
  
  NSDictionary *params =  [url parameterDictionary];
  //;hi?31,191
  CGPoint p;
  p.x = [[params objectForKey:@"x"] intValue];
  p.y = [[params objectForKey:@"y"] intValue];
  CGWarpMouseCursorPosition(p);
  
  [server replyWithStatusCode:200 message:@""];
  
  return;
  
#pragma mark keypress
} else if ([[url path] hasPrefix: @"/telekinesis"]) {
  NSDictionary *params =  [url parameterDictionary];
  if (1 || [[params objectForKey:@"t"] isEqualToString:@"keyup"]) {
    
    NSString *string = [params objectForKey:@"string"];
    
    
    int i;
    for (i = 0; i < [string length]; i++) {
      unichar c = [string characterAtIndex:i];
      
      BOOL shift = isupper(c);//[[params objectForKey:@"s"] isEqualToString:@"true"];
        
        short code = [QSKeyCodeTranslator AsciiToKeyCode:c];
        
        if (shift) CGPostKeyboardEvent( (CGCharCode)0, (CGKeyCode)56, true ); // shift down
        CGPostKeyboardEvent(0, code, YES);
        CGPostKeyboardEvent(0, code, NO);
        if (shift) CGPostKeyboardEvent( (CGCharCode)0, (CGKeyCode)56, false ); // 'shift up
    }
  }
  [server replyWithStatusCode:200 message:@""];
  
  return;
  
  
  
  
#pragma mark return path
} else {
  //components = [components subarrayWithRange:NSMakeRange(2,[components count]-2)];
  //path = [NSString pathWithComponents:components];
  path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
  
  data = [NSData dataWithContentsOfMappedFile:path];
  mime = @"";
} 

if(data && mime) {
  [server replyWithData: data
               MIMEType: mime];
} else {
  NSString *errorMsg = [NSString stringWithFormat:@"Error in URL: %@", url];
  
  [server replyWithStatusCode:400 // Bad Request
                      message:errorMsg];
}
}

- (void)stopProcessing {
  
}

@end


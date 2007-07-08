//
//  TKController.h
//  Telekinesis
//
//  Created by Nicholas Jitkoff on 6/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class HTTPServer, SimpleHTTPConnection;

@interface TKController : NSObject {
  HTTPServer *server;
  NSTask *apacheTask;
  
  int region;
  IBOutlet WebView *webView; 
  NSMutableArray *applications;
  
  IBOutlet NSTextField *userField;
  IBOutlet NSTextField *passField; 
  IBOutlet NSMenu *statusMenu; 
  IBOutlet NSWindow *prefsWindow; 
  BOOL shouldShowHomepage;
  BOOL servicesRunning;
  NSStatusItem *statusItem;
}
- (IBAction)cancelPass:(id)sender;
- (IBAction)savePass:(id)sender;
- (IBAction)choosePass:(id)sender;
- (IBAction)showPrefs:(id) sender;
- (void)setServer:(HTTPServer *)sv;
- (HTTPServer *)server;

//- (void)processURL:(NSURL *)path connection:(SimpleHTTPConnection *)connection;
//- (void)stopProcessing;

- (IBAction) restartServices:(id)sender;
- (IBAction) toggleServices:(id)sender;
- (IBAction) goHome:(id)sender;
- (IBAction) goSupport:(id)sender;
- (IBAction) goToApps:(id)sender;

- (int)portNumber;
- (int)telePortNumber;
- (int)mediaPortNumber;
@end

//
//  TKController.h
//  Telekinesis
//
//  Created by Nicholas Jitkoff on 6/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class SimpleHTTPServer, SimpleHTTPConnection;

@interface TKController : NSObject {
  SimpleHTTPServer *server;
  NSTask *apacheTask;
  
  int region;
  IBOutlet WebView *webView; 
  NSMutableDictionary *applicationsDictionary;
  
  IBOutlet NSTextField *userField;
  IBOutlet NSTextField *passField; 
  BOOL shouldShowHomepage;
}
- (IBAction)cancelPass:(id)sender;
- (IBAction)savePass:(id)sender;
- (void)setServer:(SimpleHTTPServer *)sv;
- (SimpleHTTPServer *)server;

- (void)processURL:(NSURL *)path connection:(SimpleHTTPConnection *)connection;
- (void)stopProcessing;

@end

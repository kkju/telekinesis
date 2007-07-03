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
}

- (void)setServer:(SimpleHTTPServer *)sv;
- (SimpleHTTPServer *)server;

- (void)processURL:(NSURL *)path connection:(SimpleHTTPConnection *)connection;
- (void)stopProcessing;

@end

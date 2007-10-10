//
//  LoginItemsController.h
//
//  Created by Jonas Witt on 13.05.06.
//  Copyright 2006-2007 metaquark.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LoginItemsController : NSObject {
	
	NSLock *appleScriptLock;
	
}

+ (LoginItemsController *)controller;

- (BOOL)runsAtLogin;
- (BOOL)runsAtLoginWithPath:(NSString *)path;

- (void)setRunAtLogin:(BOOL)run;
- (void)setRunAtLogin:(BOOL)run withPath:(NSString *)path;

- (void)deleteLoginItem;
- (void)deleteLoginItemWithPath:(NSString*)path;

- (void)addLoginItem;
- (void)addLoginItemWithPath:(NSString*)path;

- (NSAppleEventDescriptor *)_runScript:(NSString *)script;

@end

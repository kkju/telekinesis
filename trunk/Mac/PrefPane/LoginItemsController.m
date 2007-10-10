//
//  LoginItemsController.m
//
//  Created by Jonas Witt on 13.05.06.
//  Copyright 2006-2007 metaquark.de. All rights reserved.
//

#import "LoginItemsController.h"

@implementation LoginItemsController

+ (LoginItemsController *)controller
{
	static LoginItemsController *controller = nil;
	if (!controller)
		controller = [[LoginItemsController alloc] init];
	return controller;
}

- (id)init
{
	if (![super init])
		return nil;
	
	appleScriptLock = [[NSLock alloc] init];
	
	return self;
}

- (void)dealloc
{
	[appleScriptLock release];
	
	[super dealloc];
}

- (BOOL)runsAtLogin
{
    return [self runsAtLoginWithPath:[[NSBundle mainBundle] bundlePath]];
}

- (BOOL)runsAtLoginWithPath:(NSString *)path
{
	NSString *script = [NSString stringWithFormat:@"tell application \"System Events\" \n	repeat with the_item in login items \nif path of the_item contains \"%@\" then\n	return true\n	end if\n	end repeat\nreturn false\n end tell", [path lastPathComponent]];
	NSAppleEventDescriptor *res = [self _runScript:script];
	return [res booleanValue];
}

- (void)setRunAtLogin:(BOOL)run {
	if (run)
		[self addLoginItem];
	else 
		[self deleteLoginItem];
}

- (void)setRunAtLogin:(BOOL)run withPath:(NSString *)path
{
	if (run)
		[self addLoginItemWithPath:path];
	else 
		[self deleteLoginItemWithPath:path];
}

- (void)deleteLoginItem {
	[self deleteLoginItemWithPath:[[NSBundle mainBundle] bundlePath]];
}

- (void)deleteLoginItemWithPath:(NSString*)path
{
	[self _runScript:[NSString stringWithFormat:@"tell application \"System Events\" \nset the_index to 1\nrepeat with the_item in login items\n	if path of the_item contains \"%@\" then\n	delete login item the_index\n	set the_index to the_index - 1\nend if\nset the_index to the_index + 1\n	end repeat\n end tell", [path lastPathComponent]]];
}

- (void)addLoginItem {
	[self addLoginItemWithPath:[[NSBundle mainBundle] bundlePath]];
}

- (void)addLoginItemWithPath:(NSString *)path
{
	[self deleteLoginItemWithPath:path];
	
	[self _runScript:[NSString stringWithFormat:@"tell application \"System Events\" to make login item at end with properties {path:\"%@\", hidden:false}", path]];
}

- (NSAppleEventDescriptor *)_runScript:(NSString *)script
{
	NSAppleScript *s = [[NSAppleScript alloc] initWithSource:script];
	NSDictionary *error = nil;
	[appleScriptLock lock];
	NSAppleEventDescriptor *desc = [s executeAndReturnError:nil];
	[appleScriptLock unlock];
	if (error) {
		NSLog(@"an error occurred executing the applescript:");
		NSLog(script);
		NSLog(@"error: %@", error);
	}
	[s release];
	return desc;
}

@end

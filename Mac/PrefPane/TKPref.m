//
//  TKPref.m
//  TK
//
//  Created by alcor on 7/6/07.
//  Copyright (c) 2007 Blacktree Inc. All rights reserved.
//

#import "TKPref.h"

#import "LoginItemsController.h"
#include <sys/sysctl.h>

#define countof(a) (sizeof(a)/sizeof(a[0]))

@interface TKPref (Private)

- (void)threadStartStop;

- (NSString *)helperPath;

- (BOOL)removeHelper;

- (BOOL)copyHelper;

- (BOOL)helperIsRunningWithPID:(pid_t *)_pid;

- (BOOL)runHelper;

- (BOOL)terminateHelper;

- (void)updateLabel;

- (NSDate *)mTimeForAppBundleAtPath:(NSString *)path;

@end

@implementation TKPref

- (void) dealloc
{
	[helperPath release];
	
	[super dealloc];
}

- (void) mainViewDidLoad
{
	[self updateLabel];
}

- (IBAction) startStop:(id)sender
{
	[NSThread detachNewThreadSelector:@selector(threadStartStop) toTarget:self withObject:nil];
}

- (BOOL) helperRunning
{
	return [self helperIsRunningWithPID:nil];
}

- (void) setHelperRunning:(BOOL)run
{
	if (run)
		[self runHelper];
	else
		[self terminateHelper];
}

- (BOOL) runsAtLogin
{
	return [[LoginItemsController controller] runsAtLoginWithPath:[self helperPath]];
}

- (void) setRunsAtLogin:(BOOL)runs
{
	if (runs)
		[self copyHelper];
	
	[[LoginItemsController controller] setRunAtLogin:runs withPath:[self helperPath]];
}

@end

@implementation TKPref (Private)

- (void)threadStartStop
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[self setHelperRunning:![self helperRunning]];
	
	[self performSelectorOnMainThread:@selector(updateLabel) withObject:nil waitUntilDone:NO];	
	
	[pool release];
}

- (NSString *)helperPath
{
	if (helperPath)
		return helperPath;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    basePath = [basePath stringByAppendingPathComponent:@"iPhone Remote"];
	
    if (![[NSFileManager defaultManager] fileExistsAtPath:basePath isDirectory:NULL])
        [[NSFileManager defaultManager] createDirectoryAtPath:basePath attributes:nil];
	
	helperPath = [[basePath stringByAppendingPathComponent:@"iPhone Remote.app"] retain];
	return helperPath;
}

- (BOOL)removeHelper
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:[self helperPath]])
		return YES;
	
	return [[NSFileManager defaultManager] removeFileAtPath:[self helperPath] handler:nil];
}

- (BOOL)copyHelper
{
	NSString *target = [self helperPath];
	NSString *source = [[NSBundle bundleForClass:[self class]] pathForResource:@"iPhone Remote" ofType:@"app"];
	
	if (!source || !target)
		return NO;
			
	if ([[NSFileManager defaultManager] fileExistsAtPath:target]) {
		NSDate *sourceMTime = [self mTimeForAppBundleAtPath:source];
		NSDate *targetMTime = [self mTimeForAppBundleAtPath:target];
	
		// if the target exists and is not older than the source,
		// we don't need to copy the .app over
		if (sourceMTime && targetMTime && [sourceMTime compare:targetMTime] != NSOrderedDescending)
			return YES;
		
		if (![self removeHelper])
			return NO;
	}
		
	return [[NSFileManager defaultManager] copyPath:source toPath:target handler:nil];
}

- (BOOL)helperIsRunningWithPID:(pid_t *)_pid 
{
	int mib[3] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL };
	size_t count;
	int err;
	struct kinfo_proc *kp = NULL;
	
	do {
		if (NULL != kp) {
			free(kp);
			kp = NULL;
		}
		
		err = sysctl(mib, countof(mib), NULL, &count, NULL, 0);
		if (-1 == err)
			break;
		
		kp = (struct kinfo_proc *) malloc(count);
		if (NULL == kp)
			break;
		
		err = sysctl(mib, countof(mib), kp, &count, NULL, 0);
		if (-1 == err && ENOMEM != errno) {
			free(kp);
			kp = NULL;
			break;
		}
	} while (-1 == err);
	
	if (NULL != kp) {
		const int max = count / sizeof(struct kinfo_proc);
		int i;
		for (i = 0; i < max; ++i) {
			if (0 == strncmp(kp[i].kp_proc.p_comm, "iPhone Remote", 9) && !(kp[0].kp_proc.p_flag & P_WEXIT)) {
				if (_pid)
					*_pid = kp[i].kp_proc.p_pid;
				return YES;
			}
		}
		free(kp);
	}
	
	return NO;
}

- (BOOL)runHelper
{
	if (![self terminateHelper])
		 return NO;
		 
	if (![self copyHelper])
		 return NO;
	
	return [[NSWorkspace sharedWorkspace] openFile:[self helperPath]];
}

- (BOOL)terminateHelper
{
	pid_t pid = 0;
	if (![self helperIsRunningWithPID:&pid])
		return YES;
	
	if (kill(pid, SIGTERM) != 0)
		return NO;
	
	[self setRunsAtLogin:NO];
		
	return YES;
}

- (void)updateLabel
{
	if ([self helperIsRunningWithPID:nil]) {
		[statusField setStringValue:@"iPhone Remote is running"];
		[startStopButton setTitle:@"Stop"];
	}
	else {
		[statusField setStringValue:@"iPhone Remote is stopped"];
		[startStopButton setTitle:@"Start"];
	}
}

- (NSDate *)mTimeForAppBundleAtPath:(NSString *)path
{
	return [[[NSFileManager defaultManager] fileAttributesAtPath:[[NSBundle bundleWithPath:path] executablePath] traverseLink:NO] objectForKey:NSFileModificationDate];
}

@end



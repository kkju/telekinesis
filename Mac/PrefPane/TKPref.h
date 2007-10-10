//
//  TKPref.h
//  TK
//
//  Created by alcor on 7/6/07.
//  Copyright (c) 2007 Blacktree Inc. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>


@interface TKPref : NSPreferencePane 
{

	IBOutlet NSTextField *statusField;
	
	IBOutlet NSButton *startStopButton;
	
	NSString *helperPath;
	
}

- (void) mainViewDidLoad;

- (IBAction) startStop:(id)sender;

- (BOOL) helperRunning;
- (void) setHelperRunning:(BOOL)run;

- (BOOL) runsAtLogin;
- (void) setRunsAtLogin:(BOOL)runs;

@end

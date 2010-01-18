//
//  NSApplication_Relaunch.m
//  WellDone
//
//  Created by Christian Hattinger on 18.01.10.
//  Copyright 2010 TU Wien. All rights reserved.
//

#import "NSApplication_Relaunch.h"


@implementation NSApplication (Relaunch)

- (void)relaunch:(id)sender
{
	NSString *daemonPath = [[NSBundle mainBundle] pathForResource:NSApplicationRelaunchDaemon ofType:nil];
	
	if ( daemonPath == nil )
	{
		[self terminate:sender]; //can’t relaunch, so just quit the app
	}
	
	[NSTask launchedTaskWithLaunchPath:daemonPath arguments:[NSArray arrayWithObjects:[[NSBundle mainBundle] bundlePath], 
															 [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]], nil]];
	[self terminate:sender];
}

@end

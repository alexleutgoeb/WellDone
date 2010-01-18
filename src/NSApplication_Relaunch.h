//
//  NSApplication_Relaunch.h
//  WellDone
//
//  Created by Christian Hattinger on 18.01.10.
//  Copyright 2010 TU Wien. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define NSApplicationRelaunchDaemon @"relaunch"

@interface NSApplication (Relaunch)

- (void)relaunch:(id)sender;

@end
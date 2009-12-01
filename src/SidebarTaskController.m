//
//  SidebarTaskController.m
//  WellDone
//
//  Created by Dominik Hofer on 16/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SidebarTaskController.h"



@implementation SidebarTaskController

@synthesize datedue;

- (id) init
{

	
	self = [super initWithNibName:@"SidebarTask" bundle:nil];
	if (self != nil)
	{		
	}
	return self;
}
/*
- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
	[datedue setBezelStyle:NSRecessedBezelStyle];
	return YES;
}
*/


/**
 NSTextField Delegate Methoden
 */
- (BOOL)textShouldBeginEditing:(NSText *)textObject {
	NSLog(@"textShouldBeginEditing called");
	return YES;
}

- (BOOL)textShouldEndEditing:(NSText *)textObject {
	NSLog(@"textShouldEndEditing called");	
	return YES;
}

- (void)textDidChange:(NSNotification *)aNotification {
	NSLog(@"textDidChange called");	
}

- (void)textDidEndEditing:(NSNotification *)aNotification {
	NSLog(@"textDidEndEditing called");	
}

- (void)textDidBeginEditing:(NSNotification *)aNotification {
	NSLog(@"textDidBeginEditing called");		
}

/**
 NSControl Calls
 */
- (void)controlTextDidBeginEditing:(NSNotification *)notification {
	NSLog(@"controlTextDidBeginEditing called");
}

- (void)controlTextDidChange:(NSNotification *)aNotification {
	NSLog(@"controlTextDidChange called");	
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification {
	NSLog(@"controlTextDidEndEditing called");	
}

@end

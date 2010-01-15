//
//  SidebarTaskController.m
//  WellDone
//
//  Created by Dominik Hofer on 16/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SidebarTaskController.h"
#import "Task.h"
#import "WellDone_AppDelegate.h"


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



- (void) setRepeat:(id)sender {
	NSLog(@"Tag: %d",[[sender selectedItem] tag]);
	NSArray *selectedTasks = [[[[NSApp delegate] simpleListController] treeController] selectedObjects];
	Task *selectedTask = [selectedTasks objectAtIndex:0];
	[selectedTask setRepeat: [[NSNumber alloc] initWithInt:[[sender selectedItem] tag]]];
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

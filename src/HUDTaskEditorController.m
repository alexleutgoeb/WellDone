//
//  HUDTaskEditorController.m
//  WellDone
//
//  Created by Manuel Maly on 11.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HUDTaskEditorController.h"
#import "SimpleListController.h"
#import "WellDone_AppDelegate.h"


@implementation HUDTaskEditorController
@synthesize datedue, simpController;

- (id) init
{
	
	
	self = [super initWithWindowNibName:@"HUDTaskEditor"];
	if (self != nil)
	{		
	}
	return self;
}

- (void) awakeFromNib {
	/*NSTreeController *taskTreeController = [[[NSApp delegate] simpleListController] treeController];
	//simpController.treeController;
	
	[taskObjectController bind:@"content" toObject:taskTreeController withKeyPath:@"selection.self" options:[[NSDictionary alloc] init]];
	[estimatedWorkingTime bind:@"value" toObject:taskObjectController withKeyPath:@"selection.length" options:[[NSDictionary alloc] init]];*/
	//TODO remove this!
	
	
	// Uncomment for DatePicker usage - currently not working!
	/*NSWindow *window = [self window];
	DateTimePopupController *dateTimePopupController = [DateTimePopupController showPopupAtLocation:NSZeroPoint forWindow:window callBack:nil to: nil];*/

}


typedef enum _repeatValue
{
	never = 0, daily, weekly, monthly
} repeatValue;

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

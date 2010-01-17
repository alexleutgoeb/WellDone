//
//  ContextManagementController.m
//  WellDone
//
//  Created by Andrea F. on 22.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ContextManagementController.h"


@implementation ContextManagementController

@synthesize arrayController;

- (id) init
{
	self = [super initWithWindowNibName:@"ContextManagement"];
	if (self != nil)
	{		
		moc = [[NSApp delegate] managedObjectContext];
	}
	return self;
}

/*
 * Set the currently selected task as deleted (flag).
 */
- (IBAction) deleteSelectedContext:(id)sender {
	NSLog(@"ContextManagementController DeleteSelectedContext");
	NSArray *selectedContexts = [arrayController selectedObjects];
	id selectedContext;
	for (selectedContext in selectedContexts) {
		if ([selectedContext isKindOfClass: [Context class]]) {
			[selectedContext setDeletedByApp:[NSNumber numberWithBool:YES]];
			[myTableView reloadData]; 
			[arrayController fetch:nil];
		}
	}
	NSError *error = nil;
	if (![moc save:&error]) {
		DLog(@"Error deleting selected Context, don't know what to do: %@", error);
		//DLog(@"Error deleting selected Context, don't know what to do.");
	} else {
		DLog(@"Removed selected Context.");
	}
	
	
}

@end

//
//  ConflictResolverController.m
//  WellDone
//
//  Created by Alex Leutgöb on 17.01.10.
//  Copyright 2010 alexleutgoeb.com. All rights reserved.
//

#import "ConflictResolverController.h"
#import "Task.h"
#import "GtdTask.h"
#import "TaskContainer.h"
#import "WellDone_AppDelegate.h"


@interface ConflictResolverController ()

- (void)setActiveConflictView;

@end


@implementation ConflictResolverController

@synthesize tasks;

- (id)init {
	if (self = [super initWithWindowNibName:@"ConflictResolver"]) {
		activeConflict = 0;
	}
	return self;
}

- (void)windowDidLoad {
	DLog(@"Creating conflict resolver window...");
	
	NSInteger c = [tasks count];
	[borderBox setHidden:YES];
	[conflictTextField setStringValue:[NSString stringWithFormat:@"There %@ %i sync conflict%@.", (c == 1) ? @"is" : @"are", c, (c == 1) ? @"" : @"s"]];
	[progressTextField setStringValue:[NSString stringWithFormat:@"%i of %i", activeConflict + 1, c]];
	
    NSView *contentView = [[self window] contentView];
    [contentView setWantsLayer:YES];
	
}

- (IBAction)expandView:(id)sender {
	[self setActiveConflictView];

	NSRect frame = self.window.frame;
	frame.origin.y = frame.origin.y - 233;
	frame.size.width = 491;
	frame.size.height = 422;
	[self.window setFrame:frame display:YES animate:YES];
	[okButton setHidden:YES];
	[cancelButton setHidden:YES];
	[conflictDetailTextField setHidden:YES];
	[borderBox setHidden:NO];
}

- (IBAction)closeWindow:(id)sender {
	[self close];
}

- (void)setActiveConflictView {
	TaskContainer *container = [tasks objectAtIndex:activeConflict];
	Task *localTask = container.remoteTask.localTask;
	GtdTask *remoteTask = container.gtdTask;
	
	[localTitle setStringValue:localTask.title];
	[remoteTitle setStringValue:remoteTask.title];
	
	// TODO: set other fields
}

- (IBAction)solveConflict:(id)sender {
	TaskContainer *container = [tasks objectAtIndex:activeConflict];
	NSError *error = nil;
	NSManagedObjectContext *context = [container.remoteTask managedObjectContext];
	
	if ([segmentedChooser selectedSegment] == 0) {
		// Chose local task
		DLog(@"Overwrite remote task by local one on next sync...");
	}
	else {
		// Chose remote task
		DLog(@"Overwrite local task by remote one on next sync...");
		NSDate *modifiedDate = [container.gtdTask.date_modified addTimeInterval:-2];
		container.remoteTask.lastsyncDate = modifiedDate;
		container.remoteTask.localTask.modifiedDate = modifiedDate;
	}
	
	if (![context save:&error]) {
		// Update to handle the error appropriately.
		DLog(@"Error while saving sync context: %@, %@", error, [error userInfo]);
		NSDate *modifiedDate = [container.gtdTask.date_modified addTimeInterval:2];
		container.remoteTask.lastsyncDate = modifiedDate;
		container.remoteTask.localTask.modifiedDate = modifiedDate;
	}
	
	activeConflict++;
	
	if (activeConflict < [tasks count]) {
		// Next conflict
		[self setActiveConflictView];
	}
	else {
		// Close window
		[self closeWindow:self];
		[[NSApp delegate] startSync:self];
	}
}

@end

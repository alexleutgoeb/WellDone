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
#import "RemoteFolder.h"
#import "RemoteContext.h"
#import "Folder.h"
#import "Context.h"


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

- (void)awakeFromNib {
	DLog(@"Creating conflict resolver window...");
	
	[borderBox setHidden:YES];
	NSInteger c = [tasks count];
	[conflictTextField setStringValue:[NSString stringWithFormat:@"There %@ %i sync conflict%@.", (c == 1) ? @"is" : @"are", c, (c == 1) ? @"" : @"s"]];
	[progressTextField setStringValue:[NSString stringWithFormat:@"%i of %i", activeConflict + 1, c]];
	
    NSView *contentView = [[self window] contentView];
    [contentView setWantsLayer:YES];
	
	[self setActiveConflictView];
}

- (IBAction)expandView:(id)sender {
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
	
	if ([okButton isHidden]) {
		NSRect frame = self.window.frame;
		frame.origin.y = frame.origin.y + 233;
		frame.size.width = 491;
		frame.size.height = 189;
		[self.window setFrame:frame display:YES animate:NO];
		[okButton setHidden:NO];
		[cancelButton setHidden:NO];
		[conflictDetailTextField setHidden:NO];
		[borderBox setHidden:YES];
	}
}

- (void)setTasks:(NSArray *)theTasks {
	[tasks release];
	tasks = nil;
	if (theTasks != nil)
		tasks = [theTasks retain];
	
	activeConflict = 0;
	NSInteger c = [tasks count];
	[conflictTextField setStringValue:[NSString stringWithFormat:@"There %@ %i sync conflict%@.", (c == 1) ? @"is" : @"are", c, (c == 1) ? @"" : @"s"]];	
	[self setActiveConflictView];
}

- (void)setActiveConflictView {
	TaskContainer *container = [tasks objectAtIndex:activeConflict];
	Task *localTask = container.remoteTask.localTask;
	GtdTask *remoteTask = container.gtdTask;
	
	[localTitle setStringValue:localTask.title];
	[remoteTitle setStringValue:remoteTask.title];

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	if (localTask.dueDate != nil)
		[localDue setStringValue:[formatter stringFromDate:localTask.dueDate]];
	else
		[localDue setStringValue:@"-"];

	if (remoteTask.date_due != nil)
		[remoteDue setStringValue:[formatter stringFromDate:remoteTask.date_due]];
	else	
		[remoteDue setStringValue:@"-"];
	[formatter release];
	
	if (localTask.folder != nil)
		[localFolder setStringValue:localTask.folder.name];
	else
		[localFolder setStringValue:@"Inbox"];
	
	if (remoteTask.folder > 0) {
		NSManagedObjectContext *aManagedObjectContext = [localTask managedObjectContext];
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"RemoteFolder" inManagedObjectContext:aManagedObjectContext];
		[fetchRequest setEntity:entity];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"remoteUid == %i AND serviceIdentifier like %@", remoteTask.folder, container.remoteTask.serviceIdentifier];
		[fetchRequest setPredicate:predicate];
		NSError *error = nil;
		NSArray *allFolder = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
		if (allFolder != nil && [allFolder count] == 1) {
			// Found context
			[remoteFolder setStringValue:[[[allFolder objectAtIndex:0] localFolder] name]];
		}
		else {
			// Error, context should be in database, annoying...
		}
		[fetchRequest release];
	}
	else
		[remoteFolder setStringValue:@"Inbox"];
	
	if (localTask.context != nil)
		[localContext setStringValue:localTask.context.title];
	else
		[localContext setStringValue:@"-"];
	
	if (remoteTask.context > 0) {
		NSManagedObjectContext *aManagedObjectContext = [localTask managedObjectContext];
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"RemoteContext" inManagedObjectContext:aManagedObjectContext];
		[fetchRequest setEntity:entity];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"remoteUid == %i AND serviceIdentifier like %@", remoteTask.context, container.remoteTask.serviceIdentifier];
		[fetchRequest setPredicate:predicate];
		NSError *error = nil;
		NSArray *allContext = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
		if (allContext != nil && [allContext count] == 1) {
			// Found context
			[remoteContext setStringValue:[[[allContext objectAtIndex:0] localContext] title]];
		}
		else {
			// Error, context should be in database, annoying...
		}
		[fetchRequest release];
	}
	else
		[remoteContext setStringValue:@"-"];
	
	[localTags setStringValue:[[localTask.tags allObjects] componentsJoinedByString:@", "]];
	[remoteTags setStringValue:[remoteTask.tags componentsJoinedByString:@", "]];
	
	if (localTask.reminder != nil && [localTask.reminder intValue] > 0)
		[localRminder setStringValue:[NSString stringWithFormat:@"%@ min", localTask.reminder]];
	else
		[localRminder setStringValue:@"-"];
	
	if (remoteTask.reminder > 0)
		[remoteReminder setStringValue:[NSString stringWithFormat:@"%@ min", remoteTask.reminder]];
	else
		[remoteReminder setStringValue:@"-"];
}

- (IBAction)solveConflict:(id)sender {
	TaskContainer *container = [tasks objectAtIndex:activeConflict];
	NSError *error = nil;
	NSManagedObjectContext *context = [container.remoteTask managedObjectContext];
	
	if ([segmentedChooser selectedSegment] == 0) {
		// Chose local task
		DLog(@"Overwrite remote task by local one on next sync...");
		container.remoteTask.lastsyncDate = [container.gtdTask.date_modified addTimeInterval:1];
		container.remoteTask.localTask.modifiedDate = [container.gtdTask.date_modified addTimeInterval:2];
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

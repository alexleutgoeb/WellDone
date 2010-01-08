//
//  ContextViewController.m
//  WellDone
//
//  Created by Andrea F. on 07.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ContextViewController.h"
#import "Context.h"


@implementation ContextViewController

@synthesize simpController;

- (id) init {
	self = [super initWithNibName:@"ContextView" bundle:nil];
	if (self != nil)
	{		
	}
	return self;
}


- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row {
	
	if ([cell isKindOfClass:[NSButtonCell class]]) {
		NSButtonCell *acell = cell;
		//NSLog(@"Test");
		[acell setAction:@selector(contextsSelectionChanged)];
		[acell setTarget:self];
	}	
}

- (void)contextsSelectionChanged:(id)sender {
	NSManagedObjectContext *moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Context" inManagedObjectContext:moc];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];

	NSError *error;
	NSArray *contexts = [moc executeFetchRequest:request error:&error];
	if (contexts == nil)
	{
		// TODO: Deal with error...
	}
	[simpController setTaskListContextFilter:contexts];
}

@end

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

@synthesize simpController, arrayController;

- (id) init {
	self = [super initWithNibName:@"ContextView" bundle:nil];
	
	if (self != nil)
	{		
	}
	return self;
}

- (void) awakeFromNib {
	[checkBoxFilter setState:NSOffState];
	[self toggleFilteringByContext:nil];

}

/*
 * Set the currently selected task as deleted (flag).
 */
- (void) deleteSelectedContext {
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

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex
{
    //[items replaceObjectAtIndex:rowIndex withObject:anObject];
	[self contextsSelectionChanged];
}

- (IBAction)toggleFilteringByContext:(id)sender {
	if ([checkBoxFilter state]==NSOnState) {
		[myTableView setEnabled:YES];
	}
	else {
		[myTableView setEnabled:NO];
	}

	[self contextsSelectionChanged];
}



- (void)contextsSelectionChanged {
	if ([checkBoxFilter state]==NSOnState) {
		NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Context" inManagedObjectContext:moc];
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setEntity:entityDescription];
		
		NSError *error;
		NSArray *contexts = [moc executeFetchRequest:request error:&error];
		if (contexts == nil)
		{
			// TODO: Deal with error...
		}
		
		NSMutableArray *results = [NSMutableArray arrayWithCapacity: [contexts count]];
		Context *temp;
		for(temp in contexts) {
			NSLog(@"context %@ ischecked: %@", [temp title], [temp isChecked]);
			if([[temp isChecked] boolValue]) 
				[results addObject: temp];
		}					   
		
		[simpController setTaskListContextFilter:results];
	}
	else {
		[simpController setTaskListContextFilter: [[NSArray alloc] init]];
	}

}

@end

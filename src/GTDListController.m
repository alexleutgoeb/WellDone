//
//  GTDListController.m
//  WellDone
//
//  Created by Manuel Maly on 15.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GTDListController.h"
#import "SimpleListController.h"
#import	"SearchQuery.h"


@implementation GTDListController

#define DONE_ID @"done"
#define TASK_ID @"task"
#define DUEDATE_ID @"dueDate"
#define TAGS_ID @"tags"

@synthesize subViewControllers, section, sectionNext3Days, sectionNext7Days, sectionUpcoming;

- (id) init
{
	self = [super initWithNibName:@"GTDListView" bundle:nil];
	if (self != nil)
	{		
		//moc = [[NSApp delegate] managedObjectContext];
		moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
		
	}
	return self;
}

- (void) awakeFromNib {
	iTasks = [[NSMutableArray alloc] init];
	iGroupRowCell = [[NSTextFieldCell alloc] init];
	[iGroupRowCell setEditable:NO];
	[iGroupRowCell setLineBreakMode:NSLineBreakByTruncatingTail];	
	[gtdOutlineView expandItem:iGroupRowCell];
	
	// Initialize listening to notifications by managedObjectContext
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self selector:@selector(reactToMOCSave:)
			   name:NSManagedObjectContextDidSaveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [iGroupRowCell release];
    [super dealloc];
}


- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	NSTextFieldCell *acell = [tableColumn dataCell];
	NSTreeNode *node = item;
	if ([acell respondsToSelector:@selector(setTextColor:)]) {
		Task *task = [node representedObject];
		if ([task.completed boolValue] == YES) {
			[self setTaskDone:acell];
		} else {
			[self setTaskUndone:acell];
		}
	}
}

- (void)setTaskDone:(NSTextFieldCell*)cell {
	[cell setTextColor:[NSColor lightGrayColor]];
}

- (void)setTaskUndone:(NSTextFieldCell*)cell {
	[cell setTextColor:[NSColor blackColor]];
}

/*
 - (void)resultsOutlineDoubleClickAction:(NSOutlineView *)sender {
 // Open a page for all the selected items
 NSIndexSet *selectedRows = [sender selectedRowIndexes];
 for (NSInteger i = [selectedRows firstIndex]; i <= [selectedRows lastIndex]; i = [selectedRows indexGreaterThanIndex:i]) {
 id item = [sender itemAtRow:i];
 if ([item isKindOfClass:[Task class]]) {
 //[[NSWorkspace sharedWorkspace] openURL:[item filePathURL]];
 }
 }    
 }
 */

/*
 * This method will be called when a save-operatoin is done to the main managedObjectContext (central application delegate's moc).
 * It reacts to some of these changes with updates to the folder tree view.
 */
- (void) reactToMOCSave:(NSNotification *)notification {
	NSLog(@"reactToMOCSave");
	id object; 
	NSDictionary *userInfo = [notification userInfo];
	
	/*NSEnumerator *updatedObjects = [[userInfo objectForKey:NSUpdatedObjectsKey] objectEnumerator];
	while (object = [updatedObjects nextObject]) {
		if ([object isKindOfClass: [Task class]]) {
			[self handleUpdatedFolder: object];
			[sidebar reloadData];
		}
	}*/
	
	NSEnumerator *insertedObjects = [[userInfo objectForKey:NSInsertedObjectsKey] objectEnumerator];
	while (object = [insertedObjects nextObject]) {
		if ([object isKindOfClass: [Task class]]) {
			NSLog(@"Will insert Task with name: %@", [object name]);
			//[self addFolder:object toSection:rootNodeTaskFolders];
			//[sidebar reloadData];	
			//[self saveFolderOrderingToStore];
		}
	}
	/*
	NSEnumerator *deletedObjects = [[userInfo objectForKey:NSDeletedObjectsKey] objectEnumerator];
	while (object = [deletedObjects nextObject]) {
		if ([object isKindOfClass: [Task class]]) {
			NSLog(@"Will delete Folder with name: %@", [object name]);
			[self removeFolder: object];
			[sidebar reloadData];	
		}
	}
	*/
}

#pragma mark -
#pragma mark NSOutlineView datasource and delegate methods

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    NSArray *children = item == nil ? iTasks : [item children];
    return [children count];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    NSArray *children = item == nil ? iTasks : [item children];
    return [children objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item isKindOfClass:[Section class]]) {
        return YES;
    }
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    id result = nil;
	NSTreeNode *node = item;
	if ([[node representedObject] isKindOfClass: [Section class]]) {
		result = [[node representedObject] title];
	} else if ([[node representedObject] isKindOfClass: [Task class]]) {
        if ((tableColumn == nil) || [[tableColumn identifier] isEqualToString:TASK_ID]) {
            result = [[node representedObject] title];
            if (result == nil) {
                result = NSLocalizedString(@"(Untitled)", @"Untitled title");
            }
        } else if ([[tableColumn identifier] isEqualToString:DONE_ID]) {
            result = [[node representedObject] completed];
            if (result == nil) {
                result = NSLocalizedString(@"(Untitled)", @"Untitled title");
            }
        } else if ([[tableColumn identifier] isEqualToString:DUEDATE_ID]) {
            result = [[node representedObject] dueDate];
            if (result == nil) {
                result = NSLocalizedString(@"(No Date)", @"Untitled dueDate");
            }
        } else if ([[tableColumn identifier] isEqualToString:TAGS_ID]) {
            result = [[node representedObject] tags];
			result = NSLocalizedString(@"", @"Untitled tags");
        }            
    }
	
    return result;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	NSTreeNode *node = item;
	
	if ([[node representedObject] isKindOfClass: [Task class]]) {
        if ([[tableColumn identifier] isEqualToString:TASK_ID]) {
			[[node representedObject] setTitle:object];
        } else if ([[tableColumn identifier] isEqualToString:DONE_ID]) {
			[[node representedObject] setCompleted:object];
		} else if ([[tableColumn identifier] isEqualToString:DUEDATE_ID]) {
			[[node representedObject] setDueDate:object];
		}
    }    
}


- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    // The "nil" tableColumn is an indicator for the "full width" row
    if (tableColumn == nil) {
		if ([[item representedObject] isKindOfClass:[Section class]]) {
            return iGroupRowCell;
        } else if ([item isKindOfClass:[Task class]]) {
            // For failed items with no metdata, we also use the group row cell
            return iGroupRowCell;            
        }
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
	id representedObject = [item representedObject];
    return ([item isKindOfClass:[Section class]] || [representedObject isKindOfClass:[Section class]]);
}


// End NSOutlineView datasource and delegate methods
#pragma mark -

@end

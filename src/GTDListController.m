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

@synthesize subViewControllers;


- (id) init
{
	self = [super initWithNibName:@"GTDListView" bundle:nil];
	if (self != nil)
	{		
		moc = [[NSApp delegate] managedObjectContext];
		
	}
	return self;
}

- (void) awakeFromNib {
	
	NSLog(@"awakeFromNib called");
	iTasks = [[NSMutableArray alloc] init];
	iGroupRowCell = [[NSTextFieldCell alloc] init];
	[iGroupRowCell setEditable:NO];
	[iGroupRowCell setLineBreakMode:NSLineBreakByTruncatingTail];
	[iGroupRowCell setBackgroundColor:[NSColor blueColor]];
	[iGroupRowCell setBackgroundColor:[NSColor blackColor]];
	[self groupTasksToGTD];	
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [iGroupRowCell release];
    [super dealloc];
}


- (void)groupTasksToGTD { 
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", @"neu"];	
	NSPredicate *imagesPredicate = [NSPredicate predicateWithFormat:@"(kMDItemContentTypeTree = 'public.image')"];
	predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:imagesPredicate, predicate, nil]];
	// Create an instance of our datamodel and keep track of things.
	SearchQuery *searchQuery = [[SearchQuery alloc] initWithSearchPredicate:predicate title:@"Heute zu erledigen:"];
	[iTasks addObject:searchQuery];
	[searchQuery release];
	// Reload the children of the root item, "nil". This only works on 10.5 or higher
	[gtdOutlineView reloadItem:nil reloadChildren:YES];
	[gtdOutlineView expandItem:searchQuery];
	NSInteger row = [gtdOutlineView rowForItem:searchQuery];
	[gtdOutlineView scrollRowToVisible:row];
	[gtdOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
	
	NSLog(@"groupTasksToGTD called");
	/*
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	//NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dueDate == %@", todaysDate];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", @"neu"];
	[request setEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:moc]];
	[request setPredicate:predicate];

	NSError *error = nil;
	NSArray *results = [moc executeFetchRequest:request error:&error];
	
	// error handling code
	//[iTasks addObject:results];
	[request release];
	
	SearchQuery *searchQuery = [[SearchQuery alloc] initWithSearchPredicate:predicate title:@"WAAAA"];
	[iTasks addObject:searchQuery];
	[searchQuery release];
	// Reload the children of the root item, "nil". This only works on 10.5 or higher
	[gtdOutlineView reloadItem:nil reloadChildren:YES];
	//[gtdOutlineView expandItem:searchQuery];
	NSInteger row = [gtdOutlineView rowForItem:searchQuery];
	[gtdOutlineView scrollRowToVisible:row];
	[gtdOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];*/
	
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	NSLog(@"willDisplayCell called");
	NSTextFieldCell *acell = [tableColumn dataCell];
	
	/*if ([acell respondsToSelector:@selector(setTextColor:)]) {
		Task *task = [item representedObject];
		if ([task.completed boolValue] == YES) {
			[self setTaskDone:acell];
		} else {
			[self setTaskUndone:acell];
		}
	}*/
	[self groupTasksToGTD];
}
/*
- (void)setTaskDone:(NSTextFieldCell*)cell {
	[cell setTextColor:[NSColor lightGrayColor]];
}

- (void)setTaskUndone:(NSTextFieldCell*)cell {
	[cell setTextColor:[NSColor blackColor]];
}
*/
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
- (void)taskChildrenChanged:(NSNotification *)note {
    [gtdOutlineView reloadItem:[note object] reloadChildren:YES];
}

- (void)taskItemChanged:(NSNotification *)note {
    // When an item changes, it only will affect the display state. So, we only need to redisplay its contents, and not reload it
    NSInteger row = [gtdOutlineView rowForItem:[note object]];
    if (row != -1) {
	 [gtdOutlineView setNeedsDisplayInRect:[gtdOutlineView rectOfRow:row]];
	 if ([gtdOutlineView isRowSelected:row]) {
		 //[self updatePathControl];
	 }
	}
}
*/
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
    if ([item isKindOfClass:[SearchQuery class]]) {
        return YES;
    }
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	NSLog(@"objectValueForTableColumn called");

    id result = nil;
	//Task *task = [item representedObject];
	//NSDate *date = task.dueDate;
	//NSCalendarDate *taskDate = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate:[date timeIntervalSinceReferenceDate]];
	//NSCalendarDate *todaysDate = [NSCalendarDate calendarDate];

	
	if ([item isKindOfClass:[SearchQuery class]]) {
        if (tableColumn == nil || [[tableColumn identifier] isEqualToString:@"task"]) {
            result = [item title];
        }
    } else if ([item isKindOfClass:[SearchItem class]]) {
        if ((tableColumn == nil) || [[tableColumn identifier] isEqualToString:@"task"]) {
            result = [item title];
            if (result == nil) {
                result = NSLocalizedString(@"(Untitled)", @"Untitled title");
            }
        } else if ([[tableColumn identifier] isEqualToString:@"dueDate"]) {
            result = [item cameraModel];            
            if (result == nil) {
                result = NSLocalizedString(@"(Unknown)", @"Unknown camera model name");
            }
        } else if ([[tableColumn identifier] isEqualToString:@"tags"]) {
            result = [item modifiedDate];
        }            
    }
	/*if ([taskDate yearOfCommonEra] == [todaysDate yearOfCommonEra]) {
		if ([taskDate dayOfYear] == [todaysDate dayOfYear]) {
			if (task != nil) {
				if (tableColumn == nil || [[tableColumn identifier] isEqualToString:@"done"]) {
					result = NSLocalizedString(@"Today", @"Today title");;
				}
			} 
		} else if ([taskDate dayOfYear] <= ([todaysDate dayOfYear] + 3 )) {
			if (task != nil) {
				if (tableColumn == nil || [[tableColumn identifier] isEqualToString:@"done"]) {
					result = NSLocalizedString(@"In the next 3 days", @"Next 3 days title");;
				}
			} 
		} else if ([taskDate dayOfYear] <= ([todaysDate dayOfYear] +7)) {
			if (task != nil) {
				if (tableColumn == nil || [[tableColumn identifier] isEqualToString:@"done"]) {
					result = NSLocalizedString(@"In the next 7 days", @"Next 7 days title");;
				}
			} 
			
		}
	}*/
	
    
    return result;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([item isKindOfClass:[SearchItem class]]) {
        if ([[tableColumn identifier] isEqualToString:@"done"]) {
            [item setTitle:object];
        }
    }    
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    if ([item isKindOfClass:[SearchItem class]]) {
        SearchItem *searchItem = item;
        if ([searchItem metadataItem] != nil) {
            // We could dynamically change the thumbnail size, if desired
            return 9.0; // The extra space is padding around the cell
        }
    }
    return [outlineView rowHeight];
}


- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    // The "nil" tableColumn is an indicator for the "full width" row

    if (tableColumn == nil) {
		if ([item isKindOfClass:[SearchQuery class]]) {
            return iGroupRowCell;
        } else if ([item isKindOfClass:[SearchItem class]] && [item metadataItem] == nil) {
            // For failed items with no metdata, we also use the group row cell
            return iGroupRowCell;            
        }
		/*
		Task *task = [item representedObject];
		//NSLog(@"Task title %@ ", task.title);
        if ([task.title isEqualToString:@"neu"]) {
			[iGroupRowCell setBackgroundColor:[NSColor redColor]];
            return iGroupRowCell;
        } else if ([task.title isEqualToString:@"test"]) {
			[iGroupRowCell setBackgroundColor:[NSColor redColor]];
            return iGroupRowCell;            
        }
		 */
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return [item isKindOfClass:[SearchQuery class]];
}


// End NSOutlineView datasource and delegate methods
#pragma mark -

@end

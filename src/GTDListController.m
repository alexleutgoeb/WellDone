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
	//Task *task = [item representedObject];
	//NSDate *date = task.dueDate;
	//NSCalendarDate *taskDate = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate:[date timeIntervalSinceReferenceDate]];
	NSCalendarDate *todaysDate1 = [NSCalendarDate calendarDate];
	NSDate *todaysDate = [NSDate date];
	if (todaysDate1 == todaysDate) {
		NSLog(@"date same");
	} else {
		NSLog(@"date not same");
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
	
	
	NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"dueDate < %@", todaysDate];	
	// Create an instance of our datamodel and keep track of things.
	SearchQuery *searchQuery1 = [[SearchQuery alloc] initWithSearchPredicate:predicate1 title:@"Heute:"];
	[iTasks addObject:searchQuery1];
	NSLog(@"iTasks size %@ ", [searchQuery1 children]);
	[searchQuery1 release];
	// Reload the children of the root item, "nil". This only works on 10.5 or higher
	[gtdOutlineView reloadItem:nil reloadChildren:YES];
	[gtdOutlineView expandItem:searchQuery1];
	NSInteger row1 = [gtdOutlineView rowForItem:searchQuery1];
	[gtdOutlineView scrollRowToVisible:row1];
	[gtdOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row1] byExtendingSelection:NO];
	
	NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"dueDate > %@", todaysDate];	
	// Create an instance of our datamodel and keep track of things.
	SearchQuery *searchQuery2 = [[SearchQuery alloc] initWithSearchPredicate:predicate2 title:@"Die nächsten 3 Tage zu erledigen:"];
	[iTasks addObject:searchQuery2];
	[searchQuery2 release];
	// Reload the children of the root item, "nil". This only works on 10.5 or higher
	[gtdOutlineView reloadItem:nil reloadChildren:YES];
	[gtdOutlineView expandItem:searchQuery2];
	NSInteger row2 = [gtdOutlineView rowForItem:searchQuery2];
	[gtdOutlineView scrollRowToVisible:row2];
	[gtdOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row2] byExtendingSelection:NO];

	NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"dueDate > %@", todaysDate];	
	// Create an instance of our datamodel and keep track of things.
	SearchQuery *searchQuery3 = [[SearchQuery alloc] initWithSearchPredicate:predicate3 title:@"Die nächsten 7 Tage zu erledigen:"];
	[iTasks addObject:searchQuery3];
	[searchQuery3 release];
	// Reload the children of the root item, "nil". This only works on 10.5 or higher
	[gtdOutlineView reloadItem:nil reloadChildren:YES];
	[gtdOutlineView expandItem:searchQuery3];
	NSInteger row3 = [gtdOutlineView rowForItem:searchQuery3];
	[gtdOutlineView scrollRowToVisible:row3];
	[gtdOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row3] byExtendingSelection:NO];

	NSPredicate *predicate4 = [NSPredicate predicateWithFormat:@"dueDate > %@", todaysDate];	
	// Create an instance of our datamodel and keep track of things.
	SearchQuery *searchQuery4 = [[SearchQuery alloc] initWithSearchPredicate:predicate4 title:@"Kommende:"];
	[iTasks addObject:searchQuery4];
	[searchQuery4 release];
	// Reload the children of the root item, "nil". This only works on 10.5 or higher
	[gtdOutlineView reloadItem:nil reloadChildren:YES];
	[gtdOutlineView expandItem:searchQuery4];
	NSInteger row4 = [gtdOutlineView rowForItem:searchQuery4];
	[gtdOutlineView scrollRowToVisible:row4];
	[gtdOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row4] byExtendingSelection:NO];

}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	NSTextFieldCell *acell = [tableColumn dataCell];
	
	if ([acell respondsToSelector:@selector(setTextColor:)]) {
		/*Task *task = [item representedObject];
		if ([task.completed boolValue] == YES) {
			[self setTaskDone:acell];
		} else {
			[self setTaskUndone:acell];
		}*/
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
    id result = nil;
	//Task *task = [item representedObject];
	//NSDate *date = task.dueDate;
	//NSCalendarDate *taskDate = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate:[date timeIntervalSinceReferenceDate]];
	//NSCalendarDate *todaysDate = [NSCalendarDate calendarDate];

	
	if ([item isKindOfClass:[SearchQuery class]]) {
		NSLog(@"item isKindOfClass:[SearchQuery class]");
        if (tableColumn == nil || [[tableColumn identifier] isEqualToString:@"done"]) {
            result = [item title];
        }
    } else if ([item isKindOfClass:[Task class]]) {
		NSLog(@"item isKindOfClass:[Task class]");
        if ((tableColumn == nil) || [[tableColumn identifier] isEqualToString:@"task"]) {
            result = [item title];
            if (result == nil) {
                result = NSLocalizedString(@"(Untitled)", @"Untitled title");
            }
        } else if ([[tableColumn identifier] isEqualToString:@"dueDate"]) {
            result = [item dueDate];            
            if (result == nil) {
                result = NSLocalizedString(@"(Untitled)", @"Untitled dueDate");
            }
        } else if ([[tableColumn identifier] isEqualToString:@"tags"]) {
            result = [item tags];
			result = NSLocalizedString(@"(Untitled)", @"Untitled tags");
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
    
	NSLog(@"setObjectValue called");
	if ([item isKindOfClass:[SearchItem class]]) {
        if ([[tableColumn identifier] isEqualToString:@"done"]) {
            [item setTitle:object];
        }
    }    
}


- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    // The "nil" tableColumn is an indicator for the "full width" row

    if (tableColumn == nil) {
		if ([item isKindOfClass:[SearchQuery class]]) {
            return iGroupRowCell;
        } else if ([item isKindOfClass:[SearchItem class]]) {
            // For failed items with no metdata, we also use the group row cell
            return iGroupRowCell;            
        }
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return [item isKindOfClass:[SearchQuery class]];
}


// End NSOutlineView datasource and delegate methods
#pragma mark -

@end

//
//  GTDListController.m
//  WellDone
//
//  Created by Manuel Maly on 15.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GTDListController.h"
#import "SimpleListController.h"


@implementation GTDListController

@synthesize subViewControllers;


- (id) init
{
	self = [super initWithNibName:@"GTDListView" bundle:nil];
	if (self != nil)
	{		
		//[myview setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
		moc = [[NSApp delegate] managedObjectContext];
		
		iTasks = [[NSMutableArray alloc] init];
		iGroupRowCell = [[NSTextFieldCell alloc] init];
		[iGroupRowCell setEditable:NO];
		[iGroupRowCell setLineBreakMode:NSLineBreakByTruncatingTail];
		
		[gtdOutlineView setTarget:self];
		[gtdOutlineView setDoubleAction:@selector(resultsOutlineDoubleClickAction:)];
		[gtdOutlineView reloadItem:nil reloadChildren:YES];

		
		Task *task = [[Task alloc] init];


		[iTasks addObject:task];
		[task release];
		
		[gtdOutlineView expandItem:task];
		NSInteger row = [gtdOutlineView rowForItem:task];
		[gtdOutlineView scrollRowToVisible:row];
		[gtdOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
		 
	}
	return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [iGroupRowCell release];
    [super dealloc];
}


- (void)groupTasksToGTD { 
	
	NSString *aTitle = @"neu";
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", aTitle];
	[request setEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:moc]];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *results = [moc executeFetchRequest:request error:&error];
	//NSLog(@"DEBUG %@ ", results);
	// error handling code
	[iTasks addObject:results];
	[request release];
	
	// Reload the children of the root item, "nil". This only works on 10.5 or higher
    [gtdOutlineView reloadItem:nil reloadChildren:YES];
    [gtdOutlineView expandItem:results];
    NSInteger row = [gtdOutlineView rowForItem:results];
    [gtdOutlineView scrollRowToVisible:row];
    [gtdOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	NSTextFieldCell *acell = [tableColumn dataCell];
	
	if ([acell respondsToSelector:@selector(setTextColor:)]) {
		Task *task = [item representedObject];
		if ([task.completed boolValue] == YES) {
			[self setTaskDone:acell];
		} else {
			[self setTaskUndone:acell];
		}
	}
	[self groupTasksToGTD];
}

- (void)setTaskDone:(NSTextFieldCell*)cell {
	[cell setTextColor:[NSColor lightGrayColor]];
}

- (void)setTaskUndone:(NSTextFieldCell*)cell {
	[cell setTextColor:[NSColor blackColor]];
}


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
    if ([item isKindOfClass:[Task class]]) {
        return YES;
    }
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {


    id result = nil;
	Task *task = [item representedObject];
	NSDate *date = task.dueDate;
	NSCalendarDate *taskDate = [NSCalendarDate dateWithTimeIntervalSinceReferenceDate:[date timeIntervalSinceReferenceDate]];
	NSCalendarDate *todaysDate = [NSCalendarDate calendarDate];

	if ([taskDate yearOfCommonEra] == [todaysDate yearOfCommonEra]) {
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
	}
	
    
    return result;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([item isKindOfClass:[Task class]]) {
        if ([[tableColumn identifier] isEqualToString:@"bla"]) {
            [item setTitle:object];
        }
    }    
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    if ([item isKindOfClass:[Task class]]) {

    }
    return [outlineView rowHeight];
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    // The "nil" tableColumn is an indicator for the "full width" row
	
    if (tableColumn == nil) {
		Task *task = [item representedObject];
		//NSLog(@"Task title %@ ", task.title);
        if ([task.title isEqualToString:@"neu"]) {
			[iGroupRowCell setBackgroundColor:[NSColor redColor]];
            return iGroupRowCell;
        } else if ([task.title isEqualToString:@"test"]) {
			[iGroupRowCell setBackgroundColor:[NSColor redColor]];
            return iGroupRowCell;            
        }
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return [item isKindOfClass:[Task class]];
}


// End NSOutlineView datasource and delegate methods
#pragma mark -

@end

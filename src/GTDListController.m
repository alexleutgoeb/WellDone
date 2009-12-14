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

#define COL_IMAGE_ID @"ImageID"

- (id) init
{
	self = [super initWithNibName:@"GTDListView" bundle:nil];
	if (self != nil)
	{		
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
/*
- (void)outlineView:(NSOutlineView *)outlineView 
	willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn 
			   item:(id)item { 
	int type = [(NGSidebarObject *)item getType]; 
	switch (type) { 
		case SIDEBAR_GROUP: { 
			[cell setTitle: [item getParamValueForKey:@"NAME"] 
			   andSubTitle: @"42 unreads" 
				  withIcon: groupImage 
				   forType: type]; 
			break; 
		} // other switch cases 
	}
*/
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

    if ([item isKindOfClass:[Task class]]) {
        if (tableColumn == nil || [[tableColumn identifier] isEqualToString:COL_IMAGE_ID]) {
            result = [item title];
        }
    } else if ([item isKindOfClass:[Task class]]) {
        if ((tableColumn == nil) || [[tableColumn identifier] isEqualToString:COL_IMAGE_ID]) {
            result = [item title];
            if (result == nil) {
                result = NSLocalizedString(@"(Untitled)", @"Untitled title");
            }
        }             
    }
    return result;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([item isKindOfClass:[Task class]]) {
        if ([[tableColumn identifier] isEqualToString:COL_IMAGE_ID]) {
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
        if ([item isKindOfClass:[Task class]]) {
            return iGroupRowCell;
        } else if ([item isKindOfClass:[Task class]]) {
            // For failed items with no metdata, we also use the group row cell
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

//
//  GTDListView.m
//  WellDone
//
//  Created by Manuel Maly on 15.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GTDListView.h"
#import "GTDListController.h"
#import "WellDone_AppDelegate.h"


@implementation GTDListView

- (void)keyDown:(NSEvent *)theEvent
{
	if ([theEvent keyCode] == 51) {
		NSLog(@"keydown (del pressed) will remove the current taks");
		[[[NSApp delegate] gtdListController] deleteSelectedTask];
		//TODO: what to do with child tasks?
	} else {
		[super keyDown:theEvent];
	}
	
	//NSLog(@"keydown");
	
}

- (void)contextMenuDeleteTask: (id)sender {
	//id representedObject = [sender representedObject];
	[[[NSApp delegate] gtdListController] deleteSelectedTask];
} 

#pragma mark -
#pragma mark Context Menu

/* ============================================================================
 *  Context menu
 */

-(NSMenu*)menuForEvent:(NSEvent*)evt 
{
    NSPoint pt = [self convertPoint:[evt locationInWindow] fromView:nil];
    int row=[self rowAtPoint:pt];
    return [self defaultMenuForRow:row];
}

-(NSMenu*)defaultMenuForRow:(int)row
{
	//Select given row
	NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex:row];
	if (![self isRowSelected:row])
		[self selectRowIndexes:indexes byExtendingSelection:NO];
	
	
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Task menu"];
	if ([self isRowDeletable:row]) {
		NSMenuItem *deleteItem = [NSMenuItem alloc];
		[deleteItem initWithTitle:@"Delete Task" action:@selector(contextMenuDeleteTask:) keyEquivalent: @""];
		[deleteItem setRepresentedObject:[self itemAtRow:row]];
		
		// Uncomment and correct/change items to create addTask item
		/*if ([self mayAddTaskToRow:row]) {
		 NSMenuItem *addItem = [NSMenuItem alloc];
		 [addItem initWithTitle:@"Add Folder" action:@selector(contextMenuAddFolder:) keyEquivalent: @""];
		 [theMenu addItem:addItem];
		 }*/
		
		//Uncomment for CMD+Backspace key equivalent (seems not to work now, for whatever reason)
		/*const unichar backspace = 0x0008;
		 [deleteItem setKeyEquivalent:[NSString stringWithCharacters:&backspace length:1]];
		 [deleteItem setKeyEquivalentModifierMask:NSCommandKeyMask];*/
		
		[theMenu addItem:deleteItem];
	}
	
	if ([[theMenu itemArray] count] == 0)
		return nil;
	
    // you'll need to find a way of getting the information about the 
    // row that is to be removed to the removeSite method
    // assuming that an ivar 'contextRow' is used for this
    //contextRow = row;
	
    return theMenu;        
}

- (BOOL)isRowDeletable:(int)row {
	if (row == -1) return NO;
	
	// Uncomment to further filter out on which nodes the delete item is shown
	/*
	 id item = [self itemAtRow:row];
	 if ([item isKindOfClass: [SidebarFolderNode class]]) {
	 if ([item data] != nil)
	 return YES;
	 }*/
	return YES;
}



@end

//
//  GTDListController.h
//  WellDone
//
//  Created by Manuel Maly on 15.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Task.h"

@interface GTDListController : NSViewController {
	NSMutableArray *subViewControllers;
	IBOutlet NSOutlineView *gtdOutlineView;
	NSTextFieldCell *iGroupRowCell;
	NSMutableArray *iTasks;
	IBOutlet NSOutlineView* myview;
	NSManagedObjectContext *moc;
}

@property (nonatomic, retain) NSMutableArray *subViewControllers;
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item;
- (void)setTaskDone:(NSTextFieldCell*)cell;
- (void)setTaskUndone:(NSTextFieldCell*)cell;
- (void)groupTasksToGTD;

@end

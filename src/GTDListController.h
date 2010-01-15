//
//  GTDListController.h
//  WellDone
//
//  Created by Manuel Maly on 15.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Task.h"
#import	"Section.h"

@interface GTDListController : NSViewController {
	NSMutableArray *subViewControllers;
	IBOutlet NSOutlineView *gtdOutlineView;
	NSTextFieldCell *iGroupRowCell;
	NSMutableArray *iTasks;
	IBOutlet NSOutlineView* myview;
	NSManagedObjectContext *moc;
	Section *section, *sectionNext3Days, *sectionNext7Days, *sectionUpcoming;
}

@property (nonatomic, retain) NSMutableArray *subViewControllers;
@property (nonatomic, retain) Section *section;
@property (nonatomic, retain) Section *sectionNext3Days;
@property (nonatomic, retain) Section *sectionNext7Days;
@property (nonatomic, retain) Section *sectionUpcoming;
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item;
- (void)setTaskDone:(NSTextFieldCell*)cell;
- (void)setTaskUndone:(NSTextFieldCell*)cell;

@end

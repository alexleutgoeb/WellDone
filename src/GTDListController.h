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

/*
 *Basically objects returned in the dataSource methods will return _NSArrayControllerTreeNode objects, a private controller class. 
 *it would not be necessary to declare this interface, it would be possible to just call the observedObject method on an (id) reference 
 * to get the relevant managed object. However, "the treat warnings as errors flag" are turned on this is the best way. 
 * more info: http://allusions.sourceforge.net/articles/treeDragPart1.php
 */
@interface _NSArrayControllerTreeNodeGTD : NSObject
{
	
}
- (unsigned int)count;
- (id)observedObject;
- (id)parentNode;
- (id)nodeAtIndexPath:(id)fp8;
- (id)subnodeAtIndex:(unsigned int)fp8;
- (BOOL)isLeaf;
- (id)indexPath;
- (id)objectAtIndexPath:(id)fp8;
@end

@interface GTDListController : NSViewController {
	IBOutlet NSTreeController* treeController;
	NSArray* dragType;
	_NSArrayControllerTreeNodeGTD* draggedNode;
	NSMutableArray *subViewControllers;
	IBOutlet NSOutlineView *gtdOutlineView;
	NSTextFieldCell *iGroupRowCell;
	NSMutableArray *iTasks;
	//IBOutlet NSOutlineView* myview;
	NSManagedObjectContext *moc;
	Section *section, *sectionNext3Days, *sectionNext7Days, *sectionUpcoming, *sectionDone;
	
	// holds the control which is being edited
	NSControl *editingControl;
	
	// Holds all filter predicates (string or array representation) for the task view which are currently active
	NSMutableDictionary* taskListFilterPredicate;
	
	NSDate* todaysDate;
}

@property (nonatomic, retain) NSMutableArray *subViewControllers;
@property (nonatomic, retain, readonly) NSTreeController *treeController;
@property (nonatomic, retain) Section *section;
@property (nonatomic, retain) Section *sectionNext3Days;
@property (nonatomic, retain) Section *sectionNext7Days;
@property (nonatomic, retain) Section *sectionUpcoming;
@property (nonatomic, retain) Section *sectionDone;
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item;
- (void)setTaskDone:(NSTextFieldCell*)cell;
- (void)setTaskUndone:(NSTextFieldCell*)cell;
- (void)setTaskOverdue:(NSTextFieldCell*)cell;

- (void) reactToMOCSave:(NSNotification *)notification;
- (void) updateGTDAfterMidnight:(NSNotification *)notification;

- (NSArray *) getCurrentTags;
- (Tag *) getTagByName: (NSString *)tagName;
- (void) setTaskListFolderFilter:(Folder*) folderToFilterFor;
- (void) setTaskListContextFilter:(NSArray*) contextsToFilterFor;
- (void) setTaskListSearchFilter:(NSString*) searchText;
- (NSPredicate *) generateTaskListSearchPredicate;
- (void) reloadTaskListWithFilters;
- (void) deleteSelectedTask;


@end

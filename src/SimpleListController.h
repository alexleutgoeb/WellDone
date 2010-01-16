//
//  SimpleListController.h
//  WellDone
//
//  Created by Manuel Maly on 13.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Task.h"



/*
 *Basically objects returned in the dataSource methods will return _NSArrayControllerTreeNode objects, a private controller class. 
 *it would not be necessary to declare this interface, it would be possible to just call the observedObject method on an (id) reference 
 * to get the relevant managed object. However, "the treat warnings as errors flag" are turned on this is the best way. 
 * more info: http://allusions.sourceforge.net/articles/treeDragPart1.php
 */
@interface _NSArrayControllerTreeNode : NSObject
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


@interface SimpleListController : NSViewController {
	IBOutlet NSTreeController* treeController;
	IBOutlet NSOutlineView* myview;
	NSManagedObjectContext *moc;
	NSArray* dragType;
	_NSArrayControllerTreeNode* draggedNode;
	Task *draggedTask;
	
	
	// holds the control which is being edited
	NSControl *editingControl;
	
	// Holds all filter predicates (string or array representation) for the task view which are currently active
	NSMutableDictionary* taskListFilterPredicate;
}

@property (nonatomic, retain, readonly) NSTreeController *treeController;
- (id)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item;
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item;
- (void)setTaskDone:(NSTextFieldCell*)cell;
- (void)setTaskUndone:(NSTextFieldCell*)cell;
- (NSArray *) getCurrentTags;
- (Tag *) getTagByName: (NSString *)tagName;
- (void) setTaskListFolderFilter:(Folder*) folderToFilterFor;
- (void) setTaskListContextFilter:(NSArray*) contextsToFilterFor;
- (void) setTaskListSearchFilter:(NSString*) searchText;
- (NSPredicate *) generateTaskListSearchPredicate;
- (void) reloadTaskListWithFilters;
- (void) deleteSelectedTask;
- (Task *) getDraggedTask;
@end

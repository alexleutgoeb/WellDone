//
//  GTDListController.m
//  WellDone
//
//  Created by Manuel Maly on 15.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GTDListController.h"
#import "SimpleListController.h"
//#import	"SearchQuery.h"
#import <AppKit/NSTokenField.h>
#import <AppKit/NSTokenFieldCell.h>
#import "Tag.h"
#import "Context.h"
#import "WellDone_AppDelegate.h"

#define kFilterPredicateFolder	@"FilterPredicateFolder"
#define kFilterPredicateSearch	@"FilterPredicateSearch"
#define kFilterPredicateContext	@"FilterPredicateContext"


@interface GTDListController ()

- (BOOL)category:(NSManagedObject *)cat isSubCategoryOf:(NSManagedObject *)possibleSub;

@end

@implementation GTDListController

#define DONE_ID @"done"
#define TASK_ID @"task"
#define DUEDATE_ID @"dueDate"
#define TAGS_ID @"tags"

@synthesize subViewControllers;
@synthesize section; 
@synthesize sectionNext3Days;
@synthesize sectionNext7Days;
@synthesize sectionUpcoming;
@synthesize sectionDone;
@synthesize treeController;
@synthesize gtdOutlineView;

- (id) init
{
	self = [super initWithNibName:@"GTDListView" bundle:nil];
	NSDate *temp = [NSDate date];	
	NSCalendar* theCalendar = [NSCalendar currentCalendar];
	unsigned theUnitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |
	NSDayCalendarUnit;
	NSDateComponents* theComps = [theCalendar components:theUnitFlags fromDate:temp];
	[theComps setHour:0];
	[theComps setMinute:0];
	[theComps setSecond:0];
	todaysDate = [theCalendar dateFromComponents:theComps];
	
	if (self != nil)
	{		
		//moc = [[NSApp delegate] managedObjectContext];
		moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
		taskListFilterPredicate = [NSMutableDictionary dictionaryWithCapacity:10];
	}
	return self;
}

- (void) awakeFromNib {
	NSLog(@"Drag&Drop: awakeFromNib called");
	dragType = [NSArray arrayWithObjects: @"factorialDragType", nil];	
	[ dragType retain ]; 
	[ gtdOutlineView registerForDraggedTypes:dragType ];
	NSSortDescriptor* sortDesc = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	[ treeController setSortDescriptors:[NSArray arrayWithObject: sortDesc]];
	[ sortDesc release ];

	
	iTasks = [[NSMutableArray alloc] init];
	iGroupRowCell = [[NSTextFieldCell alloc] init];
	[iGroupRowCell setEditable:NO];
	[iGroupRowCell setSelectable:NO];
	[iGroupRowCell setLineBreakMode:NSLineBreakByTruncatingTail];	
	[gtdOutlineView expandItem:section];
	// Initialize listening to notifications by managedObjectContext
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self selector:@selector(reactToMOCSave:)
			   name:NSManagedObjectContextDidSaveNotification object:nil];
	
	[nc addObserver:self selector:@selector(updateGTDAfterMidnight:)
			   name:kNewDayNotification object:nil];
	
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [iGroupRowCell release];
    [super dealloc];
}


- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	NSTextFieldCell *acell = [tableColumn dataCell];
	
	// Uncomment to set styling in cells:
	/*
	 if ([cell isKindOfClass: [NSTextFieldCell class]]) {
	 NSFont *font = [NSFont fontWithName:@"Times-Roman" size:12.0];
	 NSArray *keys = [NSArray arrayWithObjects:NSFontAttributeName,NSBaselineOffsetAttributeName,nil];
	 
	 NSArray *values = [NSArray arrayWithObjects:font,[NSNumber numberWithFloat:100.0],nil];
	 NSDictionary *attributes = [NSDictionary dictionaryWithObjects:values forKeys:keys];
	 NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[cell stringValue] attributes:attributes];
	 //[cell setPlaceholderAttributedString:attributedString];
	 [cell setAttributedStringValue:attributedString];
	 }*/
	
	NSTreeNode *node = item;
	if ([acell respondsToSelector:@selector(setTextColor:)]) {
		Task *task = [node representedObject];
		if ([task.completed boolValue] == YES) {
			[self setTaskDone:acell];
		} else {
			if (task.dueDate != nil && [todaysDate timeIntervalSinceDate:task.dueDate] > 0) {
				[self setTaskOverdue:acell];
			}
			else  {
				[self setTaskUndone:acell];
			}
		}
	}
	
	// This is a fix for a bug in NSOutlineView, where selected cells behave strange
	// when the highlighting mode is set to SourceList:
	[acell setStringValue:[acell stringValue]];
}

- (void)setTaskDone:(NSTextFieldCell*)cell {
	[cell setTextColor:[NSColor lightGrayColor]];
}

- (void)setTaskUndone:(NSTextFieldCell*)cell {
	[cell setTextColor:[NSColor blackColor]];
}

- (void)setTaskOverdue:(NSTextFieldCell*)cell {
	if (!([cell textColor] == [NSColor redColor]))
		[cell setTextColor:[NSColor	redColor]];
}

/*
 * Set the currently selected task as deleted (flag).
 */
- (void) deleteSelectedTask {
	NSArray *selectedTasks = [treeController selectedObjects];
	id selectedTask;
	for (selectedTask in selectedTasks) {
		if ([selectedTask isKindOfClass: [Task class]]) {
			[selectedTask setDeletedByApp:[NSNumber numberWithBool:YES]];

			//[myview reloadData]; 
			[treeController fetch:nil];
		}
	}
	NSError *error = nil;
	if (![moc save:&error]) {
		DLog(@"Error deleting selected Tasks, don't know what to do.");
	} else {
		DLog(@"Removed selected Tasks.");
	}
}

//TODO: methodenkopf, unit tests, copy&paste
- (NSArray *)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell 
	completionsForSubstring:(NSString *)substring 
			   indexOfToken:(NSInteger)tokenIndex 
		indexOfSelectedItem:(NSInteger *)selectedIndex {
	
	NSLog(@"completionsForSubstring");
	
	// get all the saved tags from core data and save them into the item array
	NSArray *items = [self getCurrentTags]; 
	NSMutableArray  *result = [[NSMutableArray alloc]init];
	NSString *currentTagName = [[NSString alloc]init];
	
	for (int i = 0; i < [items count]; i++) {
		currentTagName = (NSString *) [[items objectAtIndex:i] text];
		
		// avoid to put the tagname twice into the list (in case that the typed name was in core data)
		// also filter the tags out of the list which are not substrings of the user typed tagname
		if (currentTagName != nil && ![currentTagName isEqualToString: substring] && !([currentTagName rangeOfString:substring].location == NSNotFound)){ 
			[result addObject: currentTagName];
		}
	}	
	
	[result sortUsingSelector:@selector(compare:)];
	
	// add the current typed string from the user (substring param) as the first item
	[result insertObject:substring atIndex:0];
	return result;
}

//TODO: comments, tests
- (NSArray *) getCurrentTags {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:moc];
	[fetchRequest setEntity:entity];	
	NSError *error;
	return [moc executeFetchRequest:fetchRequest error:&error]; 
}

//TODO: comments, tests
- (Tag *) getTagByName: (NSString *)tagName {
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:moc];
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(text == %@)", tagName];
	[fetchRequest setEntity:entity];	
	[fetchRequest setPredicate:predicate];	
	NSError *error;
	NSArray *result = [moc executeFetchRequest:fetchRequest error:&error];
	
	if ([result count] == 0) return nil;
	else {
		//NSLog(@"getTagByName returns: %@", [[result objectAtIndex:0] className]);
		return  [result objectAtIndex:0];
	}
}


- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{	
	NSOutlineView *o = [aNotification object];
	
    //NSLog(@"controlTextDidEndEditing, Tag: %@", [o tag]);
	
	//NSLog(@"controlTextDidEndEditing");
	
	// check if edited column is the tokenfield (tags)
	// if not then do nothing
	if ([o editedColumn] != 3) return;
	
	NSArray *tokens = [o objectValue];
	NSMutableArray *newTags = [[NSMutableArray alloc] init];
	
	//for (id token in tokens) {
	//	NSLog(@"Token: %@",token);
	//}
	
	NSString *currentTagName = [[NSString alloc]init];
	
	NSMutableArray *currentTags = [NSMutableArray arrayWithArray:[self getCurrentTags]]; //from core data
	NSMutableArray *currentTagNames = [[NSMutableArray alloc]init]; //tag 'text' from currentTags is copied in there
	
	//copy all the current TagNames into the currentTagNames array
	for (int i = 0; i < [currentTags count]; i++){
		if ([[currentTags objectAtIndex:i] text]!=nil ){ 
			[currentTagNames addObject: ((NSString *) [[currentTags objectAtIndex:i] text])];
		}
	}
	
	NSArray *selectedTasks = [[[[NSApp delegate] simpleListController] treeController] selectedObjects];
	Task *selectedTask = [selectedTasks objectAtIndex:0];
	
	// go through all tokens (it might come more than one because of copy&paste) which the user entered (tokens)
	for (int i = 0; i < [tokens count]; i++) {
		
		//check if tag already exisits (a task can't be tagged twice with the same tag name, this could be possible with copy&paste)
		currentTagName = (NSString *) [tokens objectAtIndex:i];
		if (![currentTagNames containsObject:currentTagName]){
			
			//add tag to core data
			Tag *tag = (Tag *)[NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:moc]; 
			[tag setValue:currentTagName forKey:@"text"]; 		
			
			//add tag to currentTags and currentTagNames
			[currentTags addObject:tag];
			[currentTagNames addObject:[tag text]];
			[newTags addObject:tag];
		} else {
			[newTags addObject:[self getTagByName:currentTagName]];
		}
	}
	
	//for (id token in newTags) {
	//	NSLog(@"New Token: %@",[token text]);
	//}
	
	// Tags im Task aktualisieren
	[selectedTask setTags: [NSSet setWithArray:newTags]];
	
	// moc speichern
	NSError *error = nil;
	if (![moc save:&error]) {
		DLog(@"Error updating task, don't know what to do.");
	} else {
		DLog(@"Updated tags in Task.");
	}
}

- (void) updateGTDAfterMidnight:(NSNotification *)notification {
	NSLog(@"Will updateGTDAfterMidnight");
	[[[NSApplication sharedApplication] delegate] initGTDView];
	[gtdOutlineView reloadData];
	
}

/*
 * This method will be called when a save-operatoin is done to the main managedObjectContext (central application delegate's moc).
 * It reacts to some of these changes with updates to the folder tree view.
 */
- (void) reactToMOCSave:(NSNotification *)notification {
	NSLog(@"reactToMOCSave");
	id object; 
	NSDictionary *userInfo = [notification userInfo];

	
	NSEnumerator *updatedObjects = [[userInfo objectForKey:NSUpdatedObjectsKey] objectEnumerator];
	while (object = [updatedObjects nextObject]) {
		if ([object isKindOfClass: [Task class]]) {
			NSLog(@"Will update Task with name: %@", [object title]);
			[[[NSApplication sharedApplication] delegate] initGTDView];
			[gtdOutlineView reloadData];
		}
	}
	
	NSEnumerator *insertedObjects = [[userInfo objectForKey:NSInsertedObjectsKey] objectEnumerator];
	while (object = [insertedObjects nextObject]) {
		if ([object isKindOfClass: [Task class]]) {
			NSLog(@"Will insert Task with name: %@", [object title]);
			[[[NSApplication sharedApplication] delegate] initGTDView];
			[gtdOutlineView reloadData];
		}
	}
	
	NSEnumerator *deletedObjects = [[userInfo objectForKey:NSDeletedObjectsKey] objectEnumerator];
	while (object = [deletedObjects nextObject]) {
		if ([object isKindOfClass: [Task class]]) {
			NSLog(@"Will delete Task with name: %@", [object title]);
			[[[NSApplication sharedApplication] delegate] initGTDView];
			[gtdOutlineView reloadData];
		}
	}
	
}

//------------------------------------
#pragma mark NSOutlineView datasource methods for drag&drop-- see NSOutlineViewDataSource
//---------------------------------------------------------------------------
	

- (BOOL) outlineView : (NSOutlineView *) outlineView  
		  writeItems : (NSArray*) items 
		toPasteboard : (NSPasteboard*) pboard  {
	NSLog(@"Drag&Drop: awakeFromNib called");
	[ pboard declareTypes:dragType owner:self ];		
	// items is an array of _NSArrayControllerTreeNode  
	draggedNode = [ items objectAtIndex:0 ];
	return YES;	
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
	NSLog(@"Drag&Drop: acceptDrop called");
	_NSArrayControllerTreeNode* parentNode = item;
	NSManagedObject* draggedTreeNode = [ draggedNode observedObject ];	
	[ draggedTreeNode setValue:[parentNode observedObject ] forKey:@"parentTask" ];		
	return YES;		
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
	NSLog(@"Drag&Drop: validateDrop called");
	_NSArrayControllerTreeNode* newParent = item;
	
	// drags to the root are always acceptable
	if ( newParent == NULL ) {	
		return  NSDragOperationGeneric;	
	}
	
	// Verify that we are not dragging a parent to one of it's ancestors
	// causes a parent loop where a group of nodes point to each other and disappear
	// from the control	
	NSManagedObject* dragged = [ draggedNode observedObject ];	 	 
	NSManagedObject* newP = [ newParent observedObject ];
	
	if ([self category:dragged isSubCategoryOf:newP ] ) {
		return NO;
	}		
	
	return NSDragOperationGeneric;
}

- (BOOL) category:(NSManagedObject* )cat isSubCategoryOf:(NSManagedObject* ) possibleSub {
	NSLog(@"Drag&Drop: isSubCategoryOf called");
	// Depends on your interpretation of subCategory ....
	if ( cat == possibleSub ) {	return YES; }
	
	NSManagedObject* possSubParent = [possibleSub valueForKey:@"parentTask"];	
	
	if ( possSubParent == NULL ) {	return NO; }
	
	while ( possSubParent != NULL ) {		
		if ( possSubParent == cat ) { return YES;	}
		
		// move up the tree
		possSubParent = [possSubParent valueForKey:@"parentTask"];			
	}	
	
	return NO;
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


- (void) setTaskListFolderFilter:(Folder*) folderToFilterFor {
	[taskListFilterPredicate setValue:folderToFilterFor forKey:kFilterPredicateFolder];
	[self reloadTaskListWithFilters];
}

- (void) setTaskListContextFilter:(NSArray*) contextsToFilterFor {
	[taskListFilterPredicate setValue:contextsToFilterFor forKey:kFilterPredicateContext];
	[self reloadTaskListWithFilters];
}
- (void) setTaskListSearchFilter:(NSString*) searchText {
	[taskListFilterPredicate setValue:searchText forKey:kFilterPredicateSearch];
	[self reloadTaskListWithFilters];
}

- (void) reloadTaskListWithFilters {
	NSPredicate *predicate = [self generateTaskListSearchPredicate];
	[treeController setFetchPredicate:predicate];
	NSPredicate *retrievedPredicate = [treeController fetchPredicate];
	NSLog(@"Predicate in treecontroller: %@", [retrievedPredicate predicateFormat]);
}

- (NSPredicate *) generateTaskListSearchPredicate {
	//NSString *generatedPredicateString = @"parentTask == nil";
	NSString *generatedPredicateString = @"";
	NSString *searchText = [taskListFilterPredicate objectForKey: kFilterPredicateSearch];
	NSArray *contexts = [taskListFilterPredicate objectForKey: kFilterPredicateContext];
	Folder *folder = [taskListFilterPredicate objectForKey: kFilterPredicateFolder];
	NSMutableArray *predicateArguments = [NSMutableArray arrayWithCapacity:10];
	
	// will show inbox folder if the folder is not set:
	if (folder == nil) {
		NSString *extension = [generatedPredicateString stringByAppendingString:@"folder == nil AND parentTask == nil AND deletedByApp == 0"];
		generatedPredicateString = extension;
	}
	
	if (folder != nil) {
		NSString *extension = [generatedPredicateString stringByAppendingString:@"folder == %@ AND parentTask == nil AND deletedByApp == 0"];
		generatedPredicateString = extension;
		[predicateArguments addObject:folder];
	}
	
	if (searchText != nil && ![searchText isEqualToString:@""]) {
		NSString *extension = [generatedPredicateString stringByAppendingString:@" AND title contains[cd] %@"];
		generatedPredicateString = extension;
		[predicateArguments addObject:searchText];
	}
	
	if (contexts != nil && [contexts count] > 0) {
		NSString *extension = [generatedPredicateString stringByAppendingString:@" AND context IN %@"];
		generatedPredicateString = extension;
		[predicateArguments addObject:contexts];
	}
	
	
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat: generatedPredicateString argumentArray:predicateArguments];
	DLog(@"Set predicate on Simplelist Outlineview: %@", generatedPredicateString);
	
	return predicate;
}


// End NSOutlineView datasource and delegate methods
#pragma mark -

@end

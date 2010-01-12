//
//  SimpleListController.m
//  WellDone
//
//  Created by Manuel Maly on 13.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SimpleListController.h"
#import <AppKit/NSTokenField.h>
#import <AppKit/NSTokenFieldCell.h>
#import <Tag.h>
#import <Context.h>

#define kFilterPredicateFolder	@"FilterPredicateFolder"
#define kFilterPredicateSearch	@"FilterPredicateSearch"
#define kFilterPredicateContext	@"FilterPredicateContext"

@implementation SimpleListController

@synthesize treeController;

- (id) init {
	self = [super initWithNibName:@"SimpleListView" bundle:nil];
	if (self != nil)
	{		
		[myview setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
		moc = [[NSApp delegate] managedObjectContext];
		taskListFilterPredicate = [NSMutableDictionary dictionaryWithCapacity:10];
	}
	return self;
}

- (id)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	return nil;
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
	
}

- (void)setTaskDone:(NSTextFieldCell*)cell {
	[cell setTextColor:[NSColor lightGrayColor]];
}

- (void)setTaskUndone:(NSTextFieldCell*)cell {
	[cell setTextColor:[NSColor blackColor]];
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

- (void)updateTagsInTask:(NSString*)title Tags:(NSSet*)tags
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:moc];
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(title == %@)", title];
	[fetchRequest setEntity:entity];	
	[fetchRequest setPredicate:predicate];	
	NSError *error;
	NSArray *result = [moc executeFetchRequest:fetchRequest error:&error];
	
	if ([result count] == 0) {
		//NSLog(@"Task nicht gefunden!");
		return;
	}
	else {
		//NSLog(@"getTagByName returns: %@", [[result objectAtIndex:0] className]);
		//NSLog(@"Task gefunden!");
		NSManagedObject *task = [result objectAtIndex:0];
		[task setValue:tags forKey:@"tags"];
	}
}
/*
- (BOOL)shouldFocusCell:(NSCell *)cell atColumn:(NSInteger)column row:(NSInteger)row
{
	NSLog("shouldFocusCell");
}

- (BOOL)textShouldBeginEditing:(NSText *)textObject
{
	NSLog(@"textShouldBeginEditing: %@", [textObject className]);
}
*/

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
			NSManagedObject *tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:moc]; 
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
	[self updateTagsInTask:[selectedTask title] Tags:[NSSet setWithArray:newTags]];
	
}



//------------------------------------
#pragma mark NSOutlineView datasource methods for drag&drop-- see NSOutlineViewDataSource
//---------------------------------------------------------------------------



// create a sortDescriptor based on the name attribute. This will give us an ordered tree.
- (void)awakeFromNib {	
	NSLog(@"Drag&Drop: awakeFromNib called");
	dragType = [NSArray arrayWithObjects: @"factorialDragType", nil];	
	[ dragType retain ]; 
	[ myview registerForDraggedTypes:dragType ];
	NSSortDescriptor* sortDesc = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	[ treeController setSortDescriptors:[NSArray arrayWithObject: sortDesc]];
	[ sortDesc release ];
}	

- (BOOL) outlineView : (NSOutlineView *) outlineView  
		  writeItems : (NSArray*) items 
		toPasteboard : (NSPasteboard*) pboard  {
	NSLog(@"Drag&Drop: awakeFromNib called");
	[ pboard declareTypes:dragType owner:self ];		
	// items is an array of _NSArrayControllerTreeNode  
	draggedNode = [ items objectAtIndex:0 ];
	return YES;	
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)index {
	NSLog(@"Drag&Drop: acceptDrop called");
	_NSArrayControllerTreeNode* parentNode = item;
	NSManagedObject* draggedTreeNode = [ draggedNode observedObject ];	
	[ draggedTreeNode setValue:[parentNode observedObject ] forKey:@"parentTask" ];		
	return YES;		
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(int)index {
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
	
	if ( [ self category:dragged isSubCategoryOf:newP ] ) {
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


// This method gets called by the framework but the values from bindings are used instead
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {	
	// NSLog(@"Drag&Drop: objectValueForTableColumn called");
	return NULL;
}

- (void) filterByTaskTitle: (NSString *)title {


}


/* 
 The following are implemented as stubs because they are required when 
 implementing an NSOutlineViewDataSource. Because we use bindings on the
 table column these methods are never called. The NSLog statements have been
 included to prove that these methods are not called.
 */
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	NSLog(@"Drag&Drop: numberOfChildrenOfItem called");
	return 1;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	NSLog(@"Drag&Drop: isItemExpandable called");
	return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
	NSLog(@"Drag&Drop: child called");	
	return NULL;
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
		NSString *extension = [generatedPredicateString stringByAppendingString:@"folder = nil AND parentTask == nil"];
		generatedPredicateString = extension;
	}
	
	if (folder != nil) {
		NSString *extension = [generatedPredicateString stringByAppendingString:@"folder = %@ AND parentTask == nil"];
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
	
	
	return predicate;
}

@end

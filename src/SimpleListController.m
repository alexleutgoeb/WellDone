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

@implementation SimpleListController

@synthesize treeController;

- (id) init {
	self = [super initWithNibName:@"SimpleListView" bundle:nil];
	if (self != nil)
	{		
		[myview setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
		moc = [[NSApp delegate] managedObjectContext];
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



/**
 NSTokenFieldCellDelegate Delegate Methoden
 */

//TODO: might not need this stuff
/*
 - (NSString *)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell displayStringForRepresentedObject:(id)representedObject {
 NSLog(@"displayStringForRepresentedObject");
 return representedObject; 	
 }
 */


/*
 - (NSTokenStyle)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell styleForRepresentedObject:(id)representedObject{
 NSLog(@"styleForRepresentedObject");
 NSTokenFieldCell *newCell = [[NSTokenFieldCell alloc]init];
 [newCell setTokenStyle: [tokenFieldCell tokenStyle]];
 [newCell setTextColor:[NSColor redColor]];
 [newCell setTokenStyle:NSRoundedTokenStyle];	
 [tokenFieldCell setTextColor:[NSColor redColor]];
 return [newCell tokenStyle];	
 }
 */


/*
//TODO: methodenkopf, unit tests, soll sie threadsave sein?
- (NSArray *)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell 
		   shouldAddObjects:(NSArray *)tokens 
					atIndex:(NSUInteger)index{
	
	NSLog(@"shouldAddObjects");

	//for (id token in tokens) {
	//	NSLog(@"Token: %@",[token className]);
	//}
	
	NSString *currentTagName = [[NSString alloc]init];
	
	NSArray *currentTags = [self getCurrentTags]; //from core data
	NSMutableArray  *currentTagNames = [[NSMutableArray alloc]init]; //tag 'text' from currentTags is copied in there
	
	NSMutableArray  *result = [[NSMutableArray alloc]init];
	
	//copy all the current TagNames into the currentTagNames array
	for (int i = 0; i < [currentTags count]; i++){
		if ([[currentTags objectAtIndex:i] text]!=nil ){ 
			[currentTagNames addObject: ((NSString *) [[currentTags objectAtIndex:i] text])];
		}
	}
	
	// go through all tokens (it might come more than one because of copy&paste) which the user entered (tokens)
	for (int i = 0; i < [tokens count]; i++) {
		
		//check if tag already exisits (a task can't be tagged twice with the same tag name, this could be possible with copy&paste)
		currentTagName = (NSString *) [tokens objectAtIndex:i];
		if (![currentTagNames containsObject:currentTagName]){
			
			//add tag to core data
			NSManagedObject *tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:moc]; 
			[tag setValue:currentTagName forKey:@"text"]; 		
			
		}		
		// add tag to the result list and link it with the task (if not already done, double tagging not allowed)
		[result addObject:currentTagName];
		
		Tag *tag =[self getTagByName: currentTagName] ;//TODO
		NSArray *selectedTasks = [[[[NSApp delegate] simpleListController] treeController] selectedObjects ];
		NSSet *selectedTask = [NSSet setWithObject: [selectedTasks objectAtIndex:0]];
		[tag addTasks:selectedTask];
	}

//	NSManagedObject *task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:moc]; 
//	[task setValue:@"tempTask" forKey:@"title"]; 
//	NSSet *tasks = [NSSet setWithObject:task];
//	NSManagedObject *tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:moc]; 


 // return An array of validated tokens (pasteboard)
	return result;
	//return nil;
// ------------
	NSMutableArray *a = [[NSMutableArray alloc]init];
	[a addObject: @"test"];
	return a;
}
 */
/*
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
 */
/*
- (id)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell representedObjectForEditingString:(NSString *)editingString {
	NSLog(@"representedObjectForEditingString called...");
	
	Tag *tag = [self getTagByName: editingString];
	
	if (tag == nil) {
		// Create tag
		NSLog(@"Create tag...");
		tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:moc]; 
		[tag setValue:editingString forKey:@"text"];
	}
	
	return tag;
}

- (NSString *)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell displayStringForRepresentedObject:(id)representedObject {
	NSLog(@"displayStringForRe... called");
	return [representedObject text];
}
*/
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

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
    //NSLog(@"controlTextDidEndEditing");
	
	NSTokenFieldCell *o = [aNotification object];
	
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

		
		//Tag *tag =[self getTagByName: currentTagName] ;//TODO
		
		//[tag addTasks:selectedTask];
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
	NSLog(@"Drag&Drop: objectValueForTableColumn called");
	return NULL;
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




@end

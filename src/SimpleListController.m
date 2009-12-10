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
	
}*/


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
	//TODO: errorhandling (if !=1)
	return  [result objectAtIndex:0];
}

@end

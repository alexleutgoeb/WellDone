//
//  SimpleListController.m
//  WellDone
//
//  Created by Manuel Maly on 13.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SimpleListController.h"


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

- (NSString *)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell displayStringForRepresentedObject:(id)representedObject {
	NSLog(@"test2");
	return @"Tagname";

}

- (NSArray *)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex {
	NSLog(@"tokenFieldCell");
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
	
	NSError *error;
    NSArray *items = [moc executeFetchRequest:fetchRequest error:&error];
	
	
	NSArray * result = [NSArray arrayWithObjects:substring,nil];
	
	//for (int i = 0; i < [items count]; i++) {
	//	[result [[items objectAtIndex:i] text];
	//}	
	
	return result;
	
}

@end

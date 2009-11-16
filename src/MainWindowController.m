//
//  MainWindowController.m
//  WellDone
//
//  Created by Manuel Maly on 13.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MainWindowController.h"


@implementation MainWindowController

- (void) awakeFromNib {

	
	[self willChangeValueForKey:@"simpleListController"];
	simpleListController = [[SimpleListController alloc] initWithNibName:@"SimpleListView" bundle:nil];
	simpleListController.moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
	[self didChangeValueForKey:@"simpleListController"];
	[targetView addSubview:[simpleListController view]];
	

	
	taskeditorController = [[TaskEditorController alloc] initWithWindowNibName:@"TaskEditor"];
	
	[[taskeditorController window ]orderFront:self]; 
	taskeditorController.moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
	
	 
	 
	// Sidebar Task	
	[self willChangeValueForKey:@"sidebarTaskController"];
	sidebarTaskController = [[SidebarTaskController alloc] initWithNibName:@"SidebarTask" bundle:nil];
	sidebarTaskController.moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
	[self didChangeValueForKey:@"sidebarTaskController"];
	[sidebarTaskView addSubview:[sidebarTaskController view]];
	
	
	/*
	[self willChangeValueForKey:@"gtdListController"];
	gtdListController = [[GTDListController alloc] initWithNibName:@"GTDListView" bundle:nil];
	gtdListController.moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
	[self willChangeValueForKey:@"gtdListController"];
	[targetView addSubview:[gtdListController view]];
	
	
	gtdListController.subViewControllers = [NSMutableArray array];
	[gtdListController.subViewControllers addObject: [[SimpleListController alloc] initWithNibName:@"SimpleListView" bundle:nil]];
	[gtdListController.subViewControllers addObject: [[SimpleListController alloc] initWithNibName:@"SimpleListView" bundle:nil]];
	[gtdListController.subViewControllers addObject: [[SimpleListController alloc] initWithNibName:@"SimpleListView" bundle:nil]];
	
	
	NSEnumerator* myIterator = [gtdListController.subViewControllers objectEnumerator];
	id anObject;
	float ypos = 0;
	while( anObject = [myIterator nextObject])
	{
		[anObject setMoc:[[[NSApplication sharedApplication] delegate] managedObjectContext]];
		NSPoint point = NSMakePoint(0.0, ypos);
		ypos +=100;
		[[anObject view] setFrameOrigin: point];
		[[gtdListController view] addSubview:[anObject view]];
	}
	*/
	
}

@end

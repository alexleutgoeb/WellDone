//
//  SimpleListOutlineView.m
//  WellDone
//
//  Created by Dominik Hofer on 23/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SimpleListOutlineView.h"
#import "SimpleListController.h"
#import "WellDone_AppDelegate.h"


@implementation SimpleListOutlineView

- (void)keyDown:(NSEvent *)theEvent
{
	if ([theEvent keyCode] == 51) {
		NSLog(@"keydown (del pressed) will remove the current taks");
		[[[[NSApp delegate] simpleListController] treeController] remove:self];
		//TODO: what to do with child tasks?
	} else {
		[super keyDown:theEvent];
	}
		
	//NSLog(@"keydown");

}

@end

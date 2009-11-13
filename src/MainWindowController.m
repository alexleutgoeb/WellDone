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
	//NSLog([simpleListController description]);
	[simpleListController loadView];
	[self didChangeValueForKey:@"simpleListController"];
	[targetView addSubview:[simpleListController view]];
	
}

@end

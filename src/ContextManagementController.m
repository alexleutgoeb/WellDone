//
//  ContextManagementController.m
//  WellDone
//
//  Created by Andrea F. on 22.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ContextManagementController.h"


@implementation ContextManagementController

- (id) init
{
	self = [super initWithWindowNibName:@"ContextManagement"];
	if (self != nil)
	{		
		moc = [[NSApp delegate] managedObjectContext];
	}
	return self;
}

@end

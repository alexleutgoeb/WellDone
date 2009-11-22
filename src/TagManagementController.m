//
//  TagManagementController.m
//  WellDone
//
//  Created by Andrea F. on 22.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TagManagementController.h"


@implementation TagManagementController

- (id) init
{
	self = [super initWithWindowNibName:@"TagManagement"];
	if (self != nil)
	{		
		moc = [[NSApp delegate] managedObjectContext];
	}
	return self;
}

@end

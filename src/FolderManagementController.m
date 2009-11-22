//
//  FolderManagementController.m
//  WellDone
//
//  Created by Andrea F. on 21.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FolderManagementController.h"


@implementation FolderManagementController

- (id) init
{
	self = [super initWithWindowNibName:@"FolderManagement"];
	if (self != nil)
	{		
		moc = [[NSApp delegate] managedObjectContext];
	}
	return self;
}

@end

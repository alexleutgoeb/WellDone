//
//  SidebarTaskController.h
//  WellDone
//
//  Created by Dominik Hofer on 16/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SidebarTaskController : NSViewController {
	NSManagedObjectContext *moc;
	IBOutlet NSTextField *temp;
}

@property (nonatomic, retain) NSManagedObjectContext *moc;

@end

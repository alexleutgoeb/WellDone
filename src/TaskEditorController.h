//
//  TaskEditorController.h
//  WellDone
//
//  Created by Andrea F. on 15.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TaskEditorController : NSWindowController {
	NSManagedObjectContext *moc;
}

@property (nonatomic, retain) NSManagedObjectContext *moc;

@end

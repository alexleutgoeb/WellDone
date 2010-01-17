//
//  ContextManagementController.h
//  WellDone
//
//  Created by Andrea F. on 22.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Context.h"

@interface ContextManagementController : NSWindowController {
	NSManagedObjectContext *moc;
	IBOutlet NSTableView* myTableView;
	IBOutlet NSArrayController* arrayController;
}
- (IBAction) deleteSelectedContext:(id)sender;
@property (nonatomic, retain, readonly) NSArrayController *arrayController;



@end

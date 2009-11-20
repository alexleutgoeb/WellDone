//
//  TestDataGeneratorController.h
//  WellDone
//
//  Created by Manuel Maly on 20.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TestDataGeneratorController : NSWindowController {
	NSManagedObjectContext *moc;
}

- (void) generateTasks:(id)sender;
- (void) generateTags:(id)sender;
- (void) generateFolders:(id)sender;
- (void) deleteAll:(id)sender;
- (void) performAll:(id)sender;
- (NSManagedObject *) createTask:(NSString *)title;
- (void) deleteAllObjects: (NSString *) entityName;
@end

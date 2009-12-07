//
//  TestDataGeneratorController.m
//  WellDone
//
//  Created by Manuel Maly on 20.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TestDataGeneratorController.h"

@implementation TestDataGeneratorController

- (id) init
{
	self = [super initWithWindowNibName:@"TestDataGenerator"];
	if (self != nil)
	{		
		moc = [[NSApp delegate] managedObjectContext];
	}
	return self;
}


- (void) generateTasks:(id)sender {
	NSManagedObject *parent1 = [self createTask:@"Parent Task 1"];
	NSManagedObject *parent2 = [self createTask:@"Parent Task 2"];
	NSManagedObject *parent3 = [self createTask:@"Parent Task 3"];
	
	NSManagedObject *child1 = [self createTask:@"Child Task 1"];
	NSManagedObject *child2 = [self createTask:@"Child Task 2"];
	NSManagedObject *child3 = [self createTask:@"Child Task 3"];
	
	[child1 setValue:parent1 forKey:@"parentTask"];
	[child2 setValue:parent2 forKey:@"parentTask"];
	[child3 setValue:parent3 forKey:@"parentTask"];
}

- (void) generateTags:(id)sender {
	//TODO;
}
- (void) generateFolders:(id)sender {
	[self createFolder:@"Test Folder 1"];
	[self createFolder:@"Test Folder 2"];
	[self createFolder:@"Test Folder 3"];
}

- (void) deleteAll:(id)sender {
	[self deleteAllObjects:@"Note"];
	[self deleteAllObjects:@"Folder"];
	[self deleteAllObjects:@"Context"];
	[self deleteAllObjects:@"Tag"];
	[self deleteAllObjects:@"Task"];
}
- (void) performAll:(id)sender {
	[self deleteAll: nil];
	[self generateTasks:nil];
	[self generateTags:nil];
	[self generateFolders:nil];
}


- (NSManagedObject *) createTask:(NSString *)title {
	NSManagedObject *task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:moc]; 
	[task setValue:title forKey:@"title"]; 
	return task;
}

- (NSManagedObject *) createFolder:(NSString *)name {
	NSManagedObject *folder = [NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:moc]; 
	[folder setValue:name forKey:@"name"]; 
	return folder;
}

- (void) deleteAllObjects: (NSString *) entityName  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
	
    NSError *error;
    NSArray *items = [moc executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
	
	
    for (NSManagedObject *managedObject in items) {
        [moc deleteObject:managedObject];
        NSLog(@"%@ object deleted",entityName);
    }
    if (![moc save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",entityName,error);
    }
	
}


@end

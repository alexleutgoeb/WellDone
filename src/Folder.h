//
//  Folder.h
//  WellDone
//
//  Created by Manuel Maly on 25.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Folder :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * private;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* task;
@property (nonatomic, retain) NSSet* notebook;

@end


@interface Folder (CoreDataGeneratedAccessors)
- (void)addTaskObject:(NSManagedObject *)value;
- (void)removeTaskObject:(NSManagedObject *)value;
- (void)addTask:(NSSet *)value;
- (void)removeTask:(NSSet *)value;

- (void)addNotebookObject:(NSManagedObject *)value;
- (void)removeNotebookObject:(NSManagedObject *)value;
- (void)addNotebook:(NSSet *)value;
- (void)removeNotebook:(NSSet *)value;

@end


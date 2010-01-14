//
//  Context.h
//  WellDone
//
//  Created by Andrea F. on 14.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class RemoteContext;
@class Task;

@interface Context :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * isChecked;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet* remoteContexts;
@property (nonatomic, retain) NSSet* tasks;

@end


@interface Context (CoreDataGeneratedAccessors)
- (void)addRemoteContextsObject:(RemoteContext *)value;
- (void)removeRemoteContextsObject:(RemoteContext *)value;
- (void)addRemoteContexts:(NSSet *)value;
- (void)removeRemoteContexts:(NSSet *)value;

- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet *)value;
- (void)removeTasks:(NSSet *)value;

@end


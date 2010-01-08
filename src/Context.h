//
//  Context.h
//  WellDone
//
//  Created by Alex Leutgöb on 30.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <CoreData/CoreData.h>

@class RemoteContext;
@class Task;

@interface Context :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * isChecked;
@property (nonatomic, retain) NSSet* tasks;
@property (nonatomic, retain) NSSet* remoteContexts;

@end


@interface Context (CoreDataGeneratedAccessors)
- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet *)value;
- (void)removeTasks:(NSSet *)value;

- (void)addRemoteContextsObject:(RemoteContext *)value;
- (void)removeRemoteContextsObject:(RemoteContext *)value;
- (void)addRemoteContexts:(NSSet *)value;
- (void)removeRemoteContexts:(NSSet *)value;

@end


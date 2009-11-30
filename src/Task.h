//
//  Task.h
//  WellDone
//
//  Created by Alex Leutgöb on 30.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Context;
@class Folder;
@class RemoteTask;
@class Tag;

@interface Task :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSDate * dueDate;
@property (nonatomic, retain) NSNumber * repeat;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSNumber * reminder;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSNumber * starred;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) Folder * folder;
@property (nonatomic, retain) Context * context;
@property (nonatomic, retain) Task * parentTask;
@property (nonatomic, retain) NSSet* tags;
@property (nonatomic, retain) NSSet* childTasks;
@property (nonatomic, retain) NSSet* remoteTasks;

@end


@interface Task (CoreDataGeneratedAccessors)
- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)value;
- (void)removeTags:(NSSet *)value;

- (void)addChildTasksObject:(Task *)value;
- (void)removeChildTasksObject:(Task *)value;
- (void)addChildTasks:(NSSet *)value;
- (void)removeChildTasks:(NSSet *)value;

- (void)addRemoteTasksObject:(RemoteTask *)value;
- (void)removeRemoteTasksObject:(RemoteTask *)value;
- (void)addRemoteTasks:(NSSet *)value;
- (void)removeRemoteTasks:(NSSet *)value;

@end


//
//  Tag.h
//  WellDone
//
//  Created by Alex Leutgöb on 30.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Task;

@interface Tag :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * deletedByApp;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet* tasks;

@end


@interface Tag (CoreDataGeneratedAccessors)
- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet *)value;
- (void)removeTasks:(NSSet *)value;

@end


//
//  Task.h
//  WellDone
//
//  Created by Manuel Maly on 25.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Context;
@class Folder;
@class Tag;

@interface Task :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * reminder;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSDate * date_modified;
@property (nonatomic, retain) NSNumber * star;
@property (nonatomic, retain) NSNumber * repeat;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * date_start;
@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSDate * date_created;
@property (nonatomic, retain) NSDate * date_due;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) Folder * folder;
@property (nonatomic, retain) Context * context;
@property (nonatomic, retain) NSSet* tag;
@property (nonatomic, retain) NSSet* childTask;
@property (nonatomic, retain) NSManagedObject * parentTask;

@end


@interface Task (CoreDataGeneratedAccessors)
- (void)addTagObject:(Tag *)value;
- (void)removeTagObject:(Tag *)value;
- (void)addTag:(NSSet *)value;
- (void)removeTag:(NSSet *)value;

- (void)addChildTaskObject:(NSManagedObject *)value;
- (void)removeChildTaskObject:(NSManagedObject *)value;
- (void)addChildTask:(NSSet *)value;
- (void)removeChildTask:(NSSet *)value;

@end


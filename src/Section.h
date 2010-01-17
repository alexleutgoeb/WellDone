//
//  Section.h
//  WellDone
//
//  Created by Andrea F. on 17.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Task;

@interface Section :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * title;
@property (nonatomic, retain) NSSet* childTasks;

@end


@interface Section (CoreDataGeneratedAccessors)
- (void)addChildTasksObject:(Task *)value;
- (void)removeChildTasksObject:(Task *)value;
- (void)addChildTasks:(NSSet *)value;
- (void)removeChildTasks:(NSSet *)value;

@end


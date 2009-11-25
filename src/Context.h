//
//  Context.h
//  WellDone
//
//  Created by Manuel Maly on 25.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Context :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet* Task;

@end


@interface Context (CoreDataGeneratedAccessors)
- (void)addTaskObject:(NSManagedObject *)value;
- (void)removeTaskObject:(NSManagedObject *)value;
- (void)addTask:(NSSet *)value;
- (void)removeTask:(NSSet *)value;

@end


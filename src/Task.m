// 
//  Task.m
//  WellDone
//
//  Created by Alex Leutgöb on 30.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "Task.h"

#import "Context.h"
#import "Folder.h"
#import "RemoteTask.h"
#import "Tag.h"
#import "Section.h"

@implementation Task 

@dynamic status;
@dynamic title;
@dynamic completed;
@dynamic deletedByApp;
@dynamic dueDate;
@dynamic repeat;
@dynamic priority;
@dynamic modifiedDate;
@dynamic reminder;
@dynamic length;
@dynamic starred;
@dynamic note;
@dynamic startDate;
@dynamic createDate;
@dynamic folder;
@dynamic context;
@dynamic parentTask;
@dynamic tags;
@dynamic childTasks;
@dynamic remoteTasks;
@dynamic section;

- (void)awakeFromInsert {
	[super awakeFromInsert];
	self.createDate = [NSDate date];
	self.modifiedDate = [NSDate date];
	self.deletedByApp = [NSNumber numberWithBool:NO];
	self.completed = [NSNumber numberWithBool:NO];
	self.starred = [NSNumber numberWithBool:NO];
}

- (NSString *)description {
	return self.title;
}

- (id)children 
{
    return nil;
}

@end

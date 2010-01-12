// 
//  Tag.m
//  WellDone
//
//  Created by Alex Leutgöb on 30.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "Tag.h"

#import "Task.h"

@implementation Tag 

@dynamic deleted;
@dynamic text;
@dynamic tasks;

- (void)awakeFromInsert {
	[super awakeFromInsert];
	self.deleted = [NSNumber numberWithBool:NO];
}

- (NSString *)description {
	return self.text;
}

@end

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

@dynamic deletedByApp;
@dynamic text;
@dynamic tasks;

- (void)awakeFromInsert {
	[super awakeFromInsert];
	self.deletedByApp = [NSNumber numberWithBool:NO];
}

- (NSString *)description {
	return self.text;
}

@end

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

- (void)awakeFromInsert {
	[super awakeFromInsert];
	self.deletedByApp = [NSNumber numberWithBool:NO];
}

@end

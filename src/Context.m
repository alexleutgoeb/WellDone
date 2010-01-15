// 
//  Context.m
//  WellDone
//
//  Created by Andrea F. on 14.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Context.h"

#import "RemoteContext.h"
#import "Task.h"

@implementation Context 

@dynamic isChecked;
@dynamic title;
@dynamic deletedByApp;
@dynamic modifiedDate;
@dynamic remoteContexts;
@dynamic tasks;

- (void)awakeFromInsert {
	[super awakeFromInsert];
	self.modifiedDate = [NSDate date];
	self.deletedByApp = [NSNumber numberWithBool:NO];
}

@end

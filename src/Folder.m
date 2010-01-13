// 
//  Folder.m
//  WellDone
//
//  Created by Alex Leutgöb on 30.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "Folder.h"

#import "Note.h"
#import "RemoteFolder.h"
#import "Task.h"

@implementation Folder 

@dynamic deleted;
@dynamic order;
@dynamic modifiedDate;
@dynamic createDate;
@dynamic private;
@dynamic name;
@dynamic tasks;
@dynamic notebooks;
@dynamic remoteFolders;

- (void)awakeFromInsert {
	//DLog(@"XXXXXXXXXXXXXXXXXXX ADAFSGDG XXXXXXXXXXXXXXXX");
	[super awakeFromInsert];
	self.createDate = [NSDate date];
	self.modifiedDate = [NSDate date];
	self.deleted = [NSNumber numberWithBool:NO];
}

- (NSString *)description {
	return self.name;
}

@end

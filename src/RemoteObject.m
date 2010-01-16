// 
//  RemoteObject.m
//  WellDone
//
//  Created by Alex Leutgöb on 30.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "RemoteObject.h"


@implementation RemoteObject 

@dynamic lastsyncDate;
@dynamic remoteUid;
@dynamic serviceIdentifier;

- (void)awakeFromInsert {
	[super awakeFromInsert];
	self.lastsyncDate = nil;
	self.remoteUid = [NSNumber numberWithInt:-1];
	self.serviceIdentifier = nil;
}

@end

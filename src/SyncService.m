//
//  SyncService.m
//  WellDone
//
//  Created by Alex Leutgöb on 12.12.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "SyncService.h"


@implementation SyncService

@synthesize user, pwd;

- (id)initWithApiClass:(Class)anApiClass {
	if (self = [self init]) {
		ApiClass = anApiClass;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	;
	return self;
}

- (void)dealloc {
	ApiClass = NULL;
	api = nil;
	[pwd release];
	[user release];
	[super dealloc];
}

- (NSString *)description {
	return self.identifier;
}

- (NSString *)identifier {
	return [ApiClass identifier];
}

- (BOOL)isEnabled {
	return api == nil ? NO : YES;
}

- (BOOL)activateService:(NSError **)error {
	DLog(@"Trying to activate sync service...");
	
	if (self.user != nil && self.pwd != nil) {

		api = [[ApiClass alloc] initWithUsername:user password:pwd error:&*error];
		
		if (api == nil || error != nil) {
			DLog(@"Error while activating sync service: %@", [*error localizedDescription]);
			return NO;
		}
		else {
			return YES;
		}
	}
	else {
		DLog(@"User/pwd not set.");
		return NO;
	}
}

@end

//
//  SyncController.m
//  WellDone
//
//  Created by Alex Leutgöb on 12.12.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "SyncController.h"
#import "SyncManager.h"
#import "SyncService.h"
#import "TDApi.h"

@implementation SyncController

@synthesize syncServices;

- (id)init {
	if (self = [super init]) {
		syncServices = [[NSMutableDictionary alloc] init];
		syncManager = [[SyncManager alloc] initWithDelegate:self];
		
		// Add TDApi to available syncServices
		[syncServices setObject:[[SyncService alloc] initWithApiClass:[TDApi class]] forKey:[TDApi identifier]];
	}
	return self;
}

- (void) dealloc {
	[syncManager release];
	[syncServices removeAllObjects];
	[syncServices release];
	[super dealloc];
}

- (BOOL)enableSyncService:(NSString *)anIdentifier WithUser:(NSString *)aUser andPwd:(NSString *)aPwd {
	BOOL returnValue = NO;
	NSError *error = nil;
	
	SyncService *service = [syncServices objectForKey:anIdentifier];
	
	if (service != nil) {
		service.user = aUser;
		service.pwd = aPwd;
		returnValue = [service activateService:&error];
	}
	
	DLog(@"Service activated: %i, error: %@", returnValue, [error localizedDescription]);
	
	return returnValue;
}
- (BOOL)disableSyncService:(NSString *)anIdentifier {
	BOOL returnValue = NO;
	
	return returnValue;
}

@end

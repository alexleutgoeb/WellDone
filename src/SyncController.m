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
		syncQueue = [[NSOperationQueue alloc] init];
		// Set operation count to 1, so that max 1 sync is active
		[syncQueue setMaxConcurrentOperationCount:1];
		
		// Add TDApi to available syncServices
		[syncServices setObject:[[SyncService alloc] initWithApiClass:[TDApi class]] forKey:[TDApi identifier]];
	}
	return self;
}

- (void) dealloc {
	[syncQueue cancelAllOperations];
	[syncQueue release];
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
		if (returnValue != NO) {
			[syncManager registerSyncService:service.api];
		}
	}
	
	DLog(@"Service activated: %i, error: %@", returnValue, [error localizedDescription]);
	
	return returnValue;
}

- (BOOL)disableSyncService:(NSString *)anIdentifier {
	BOOL returnValue = NO;
	
	return returnValue;
}

- (void)sync {
	// TODO: check for internet connection to services
	
	// Get new objectcontext from delegate
	NSManagedObjectContext *mainContext = [[NSApp delegate] managedObjectContext];
	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
	[context setPersistentStoreCoordinator:[mainContext persistentStoreCoordinator]];
	
	// call syncmanager in background thread
	
	
	// after completion saveand inform delegate
	
}

- (void)syncFinished {
	// merge moc with deactived undo manager
	NSError *error = nil;
	[mainContext setMergePolicy:NSRollbackMergePolicy];
	[context save:&error];
	
	if (error != nil) {
		// save error
	}
	else {
		
	}
}

@end

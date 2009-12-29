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
		
		// TODO: start in background thread ?
		// Activated services from user defaults
		NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
		NSMutableDictionary *defaultServices = [NSMutableDictionary dictionaryWithDictionary:[userPreferences objectForKey:@"syncServices"]];
		
		if (defaultServices != nil) {
			for (NSString *serviceKey in [defaultServices allKeys]) {
				NSDictionary *service = [defaultServices objectForKey:serviceKey];
				
				if ([[service objectForKey:@"enabled"] boolValue] != NO) {
					// activate service
					if ([service objectForKey:@"username"] != nil && [service objectForKey:@"password"] != nil) {
						BOOL success = [self enableSyncService:serviceKey withUser:[service objectForKey:@"username"] pwd:[service objectForKey:@"password"] error:nil];
						DLog(@"Activate service '%@' at startup successful: %i.", serviceKey, success);
						// TODO: if not successful try later with timer or deactivate service automatically ?
					}
				}
			}
		}
		
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

- (BOOL)enableSyncService:(NSString *)anIdentifier withUser:(NSString *)aUser pwd:(NSString *)aPwd error:(NSError **)anError {
	BOOL returnValue = NO;
	
	SyncService *service = [syncServices objectForKey:anIdentifier];
	
	if (service != nil) {
		service.user = aUser;
		service.pwd = aPwd;
		returnValue = [service activate:*&anError];
		if (returnValue != NO) {
			[syncManager registerSyncService:service.api];
		}
	}
	
	DLog(@"Service activated: %i, error: %@", returnValue, [*anError localizedDescription]);
	
	return returnValue;
}

- (BOOL)disableSyncService:(NSString *)anIdentifier {
	BOOL returnValue = NO;
	
	SyncService *service = [syncServices objectForKey:anIdentifier];
	
	if (service != nil) {
		[service deactivate];
		[syncManager unregisterSyncService:service.api];
		returnValue = YES;
		DLog(@"Service deactivated.");
	}
	else {
		DLog(@"Service not found, nothing to do, returning NO.");
	}
	
	return returnValue;
}

- (void)sync {
	// TODO: check for internet connection to services
	
	// Get new objectcontext from delegate
	NSManagedObjectContext *mainContext = [[NSApp delegate] managedObjectContext];
	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
	[context setPersistentStoreCoordinator:[mainContext persistentStoreCoordinator]];
	
	// call syncmanager in background thread
	
	
	// after completion save and inform delegate

	// merge moc with deactivated undo manager
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

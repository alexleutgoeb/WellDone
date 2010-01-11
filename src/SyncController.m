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
#import "SFHFKeychainUtils.h"

@interface SyncController ()

- (void)enableAllServices;
- (void)syncContextDidSave:(NSNotification*)saveNotification;

@end


@implementation SyncController

@synthesize syncServices, activeServicesCount;

- (id)init {
	if (self = [super init]) {
		syncServices = [[NSMutableDictionary alloc] init];
		syncManager = [[SyncManager alloc] initWithDelegate:self];
		syncQueue = [[NSOperationQueue alloc] init];
		// Set operation count to 1, so that max 1 sync is active
		[syncQueue setMaxConcurrentOperationCount:1];
		activeServicesCount = 0;
		
		// Add TDApi to available syncServices
		[syncServices setObject:[[SyncService alloc] initWithApiClass:[TDApi class]] forKey:[TDApi identifier]];
		
		// TODO: start in background thread !!!!!
		NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(enableAllServices) object:nil];
		[syncQueue addOperation:op];
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

- (void)enableAllServices {
	// Activated services from user defaults
	NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *defaultServices = [NSMutableDictionary dictionaryWithDictionary:[userPreferences objectForKey:@"syncServices"]];
	
	if (defaultServices != nil) {
		for (NSString *serviceKey in [defaultServices allKeys]) {
			NSDictionary *service = [defaultServices objectForKey:serviceKey];
			
			if ([[service objectForKey:@"enabled"] boolValue] != NO) {
				// activate service
				
				// Get password for service
				NSError *error = nil;
				NSString *serviceName = [NSString stringWithFormat:@"%@ <%@>", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"], serviceKey];
				NSString *password = [SFHFKeychainUtils getPasswordForUsername:[service objectForKey:@"username"] andServiceName:serviceName error:&error];
				if (error != nil) {
					DLog(@"Error while saving to keychain: %@.", error);
				}
				
				if ([service objectForKey:@"username"] != nil && error == nil) {
					BOOL success = [self enableSyncService:serviceKey withUser:[service objectForKey:@"username"] pwd:password error:nil];
					DLog(@"Activate service '%@' at startup successful: %i.", serviceKey, success);
					// TODO: if not successful try later with timer or deactivate service automatically ?
				}
			}
		}
	}
}

- (NSInteger)servicesCount {
	return [syncServices count];
}

- (BOOL)enableSyncService:(NSString *)anIdentifier withUser:(NSString *)aUser pwd:(NSString *)aPwd error:(NSError **)anError {
	BOOL returnValue = NO;
	
	SyncService *service = [syncServices objectForKey:anIdentifier];
		
	if (service != nil) {
		DLog(@"Trying to enable sync service with user: %@.", aUser);

		service.user = aUser;
		service.pwd = aPwd;
		returnValue = [service activate:*&anError];
		if (returnValue != NO) {
			[syncManager registerSyncService:service.api];
		}
	}
	
	if (returnValue == NO) {
		DLog(@"Service not enabled: %@.", *anError);
	}
	else {
		DLog(@"Service enabled.");
		activeServicesCount++;
	}
	
	// Remove password from memory
	service.pwd = nil;
	
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
		activeServicesCount--;
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
	DLog(@"Start sync in operation queue.");
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(startSync:) object:context];
	[syncQueue addOperation:op];
	[context release];	
}

- (void)startSync:(NSManagedObjectContext *)moc {
	// TODO: start syncmanager
	// after completion save and inform delegate
	NSManagedObjectContext *context = [syncManager syncData:moc];
	
	// TODO: merge moc with deactivated undo manager
	NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
	[dnc addObserver:self selector:@selector(syncContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:context];
	
	NSError *error;
	if (![context save:&error]) {
		// Update to handle the error appropriately.
		DLog(@"Error while saving sync context: %@, %@", error, [error userInfo]);
	}
	[dnc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
}

- (void)syncContextDidSave:(NSNotification*)saveNotification {
	DLog(@"Merge sync context in main context...");
	NSManagedObjectContext *mainContext = [[NSApp delegate] managedObjectContext];
	[mainContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    [mainContext mergeChangesFromContextDidSaveNotification:saveNotification];      
}

@end

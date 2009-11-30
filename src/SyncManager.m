//
//  SyncManager.m
//  WellDone
//
//  Created by Alex Leutgöb on 28.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "SyncManager.h"
#import "Folder.h"
#import "RemoteFolder.h"


@interface SyncManager()

@property (nonatomic, retain) NSMutableDictionary *syncServices;

@end



@implementation SyncManager

@synthesize delegate;
@synthesize syncServices;


#pragma mark -
#pragma mark general methods

-(id)initWithDelegate:(id)aDelegate {
	if (self = [self init]) {
		delegate = aDelegate;
	}
	return self;
}

-(id)init {
	if (self =[super init]) {
		syncServices = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc {
	[syncServices release];
	self.delegate = nil;
	[super dealloc];
}



#pragma mark -
#pragma mark sync manager methods

- (void)registerSyncService:(id<GtdApi>)aSyncService {
	
	if ([(NSObject *)aSyncService conformsToProtocol:@protocol(GtdApi)] != NO) {
		// syncService is a valid GtdApi implementation
		[syncServices setObject:aSyncService forKey:[aSyncService identifier]];
		DLog(@"Registered sync service '%@'.", [aSyncService identifier]);
	}
	else {
		// syncService does not conform to protocol, not added
		DLog(@"Sync service '%@' does not conform to protocol, not added.", [aSyncService identifier]);
	}
}

- (void)unregisterSyncService:(id<GtdApi>)aSyncService {
	if ([syncServices objectForKey:aSyncService.identifier] != nil) {
		[syncServices removeObjectForKey:aSyncService.identifier];
	}
}

- (void)unregisterSyncServiceWithIdentifier:(NSString *)anIdentifier {
	if ([syncServices objectForKey:anIdentifier] != nil) {
		[syncServices removeObjectForKey:anIdentifier];
	}
}

- (NSManagedObjectContext *)syncDataFromManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext {
	// TODO: implement
	
	if ([syncServices count] > 0) {
		
		// Take only the first sync service from the list
		id<GtdApi> syncService = [syncServices objectForKey:[[syncServices allKeys] objectAtIndex:0]];
		NSError *error = nil;
		
		// last edited dates
		NSDictionary *lastDates = [syncService getLastModificationsDates:&error];
		
		if (lastDates != nil && error == nil) {
				
			// folder sync
			
			// TODO: check if remote folders have changed since last sync, dummy var:
			BOOL remoteFoldersHaveChanged = YES;
			
			if (remoteFoldersHaveChanged) {
				// pull folders from server
				NSArray *remoteFolders = [syncService getFolders:&error];
				if (remoteFolders != nil && error == nil) {
					// check remote folders and local folders
					
				}
			}
			else {
				// remote folders not changed, send local changes to remote if exist
			}
		}
		
		return aManagedObjectContext;
	}
	else {
		// no sync service registered, return nil
		return nil;
	}
}

- (NSManagedObjectContext *)replaceLocalDataWithRemoteData:(NSManagedObjectContext *)aManagedObjectContext {

	DLog(@"Replacing local data with remote...");
	
	if ([syncServices count] > 0) {
		
		// Take only the first sync service from the list
		id<GtdApi> syncService = [syncServices objectForKey:[[syncServices allKeys] objectAtIndex:0]];
		DLog(@"Using sync service: '%@'.", [syncService identifier]);
		NSError *error = nil;
		
		// First check if remote folders are accessible
		NSArray *remoteFolders = [syncService getFolders:&error];
		if (remoteFolders != nil && error == nil) {
			// ok, remove local data
			error = nil;
			NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
			NSEntityDescription *entity = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:aManagedObjectContext];
			[fetchRequest setEntity:entity];
			NSArray *items = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
			[fetchRequest release];
			
			for (NSManagedObject *managedObject in items) {
				DLog(@"Delete folder: %@", managedObject);
				[aManagedObjectContext deleteObject:managedObject];
			}
			
			if (![aManagedObjectContext save:&error]) {
				// TODO: error handling?
				DLog(@"Error deleting all folders, don't know what to do.");
				return nil;
			}
			else {
				// all folders deleted, store remote
				for (GtdFolder *gtdFolder in remoteFolders) {
					// Add new entities
					RemoteFolder *rFolder = [NSEntityDescription insertNewObjectForEntityForName:@"RemoteFolder" inManagedObjectContext:aManagedObjectContext];
					Folder *lFolder = [NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:aManagedObjectContext];
					
					// Set entity attributes
					rFolder.serviceIdentifier = syncService.identifier;
					rFolder.remoteUid = [NSNumber numberWithInteger:gtdFolder.uid];
					rFolder.lastsyncDate = [NSDate date];
					rFolder.localFolder = lFolder;
					lFolder.name = gtdFolder.title;
					lFolder.private = [NSNumber numberWithBool:gtdFolder.private];
					lFolder.order = [NSNumber numberWithInteger:gtdFolder.order];
					
					DLog(@"Added folder: %@", lFolder);
				}
				
				// all ok
				return aManagedObjectContext;
			}
			
		}
		else {
			DLog(@"Error while loading remote folders: %@", error);
			return nil;
		}
		
	}
	else {
		// no sync service registered, return nil
		return nil;
	}
	
}

@end

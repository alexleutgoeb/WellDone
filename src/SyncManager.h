//
//  SyncManager.h
//  WellDone
//
//  Created by Alex Leutgöb on 28.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GtdApi.h"


/**
 SyncManager class
 The SyncManager class handles synchronisation with different sync services which 
 conform to the formal GtdApi protocol. The manager detects syncing conflicts which 
 will be reported to the designated delegate object.
 */
@interface SyncManager : NSObject {
@private
	id delegate;
	NSMutableDictionary *syncServices;
}

@property (nonatomic, assign) id delegate;

/**
 Custom initializer with delegate object
 Initializes a new SyncManager object with the given delegate. The delegate must 
 implement the SyncManagerDelegate protocol and is used to inform about sync 
 conflicts.
 @param aDelegate		the delegate to be set
 @return				the initialized object, or nil if an error occured
 */
-(id)initWithDelegate:(id)aDelegate;

/**
 Adds a sync service to the manager
 The method adds a sync servce, which must conform to the GtdApi-protocol, to 
 the sync manager. The new service will be used for the next triggered syncing.
 @param aSyncService	the sync service which should be added
 */
- (void)registerSyncService:(id<GtdApi>)aSyncService;

/**
 Removes a sync service reference from the manager
 After calling this method, the specific sync service will be removed from the 
 sync service list, so that the service will not be synchronized in future calls.
 @param aSyncService	the sync service object which should be unregistered
 */
- (void)unregisterSyncService:(id<GtdApi>)aSyncService;

/**
 Removes a sync service reference from the manager
 After calling this method, the specific sync service will be removed from the 
 sync service list, so that the service will not be synchronized in future calls.
 @param anIdentifier	the sync service identifier of the object which should be 
						unregistered
 */
- (void)unregisterSyncServiceWithIdentifier:(NSString *)anIdentifier;

/**
 Main method for sync
 This method is the main method for syncing a managed object context with remote 
 data, fetched from the different sync services.
 */
- (NSManagedObjectContext *)syncData:(NSManagedObjectContext *)aManagedObjectContext conflicts:(NSArray **)conflicts;

/**
 Method for folder sync
 
 */
- (NSManagedObjectContext *)syncFolders:(NSManagedObjectContext *)aManagedObjectContext withSyncService:(id<GtdApi>)syncService;

-(NSManagedObjectContext *)syncTasks:(NSManagedObjectContext *)aManagedObjectContext withSyncService:(id<GtdApi>)syncService andConflicts:(NSArray **)conflicts;

/**
 Overrides local data with remote
 The method replaces the local data with remote entries. Warning: All local 
 data will be deleted.
 */
- (NSManagedObjectContext *)replaceLocalData:(NSManagedObjectContext *)aManagedObjectContext;


@end

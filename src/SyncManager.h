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
 Creates remoteFolders for localFolders.
 Decides wheter folders should be added, deleted or edited locally and remotely.
 Removes deleted folders from DB.
 @author Michael
 */
- (NSManagedObjectContext *)syncFolders:(NSManagedObjectContext *)aManagedObjectContext withSyncService:(id<GtdApi>)syncService;

/**
 Method for context sync
 Creates remoteContexts for localContexts.
 Decides wheter contexts should be added, deleted or edited locally and remotely.
 Removes deleted contexts from DB.
 @author Michael
 */
- (NSManagedObjectContext *)syncContexts:(NSManagedObjectContext *)aManagedObjectContext withSyncService:(id<GtdApi>)syncService;

/**
 Method for task sync
 Creates remoteTasks for localTasks.
 Decides wheter Tasks should be added, deleted or edited locally and remotely or 
 creates Conflicts if both the local modifiedDate and remoteModifiedDate are > lastsyncDate.
 Removes deleted tasks from DB.
 @author Michael, Alex
 */
- (NSManagedObjectContext *)syncTasks:(NSManagedObjectContext *)aManagedObjectContext withSyncService:(id<GtdApi>)syncService andConflicts:(NSArray **)conflicts;


/*
 
 syncpseudocode:
 
 1. via syncService die gtdFolders holen.
 
 2. aus dem managedObjectContext die remoteFolders holen.
 
 3. jetzt iteriere ich die remoteFolders durch und schau bei jedem ob es einen entsprechenden gtdFolder gibt.
 
 3a Wenn ich einen passenden gtdFolder finde dann als nächstes remoteFolder.localFolder.deleted prüfen:
 wenn deletedByApp = true: lösche gtdFolder
 sonst als nächstes das remoteFolder.localFolder lastmodified prüfen:
 wenn lastmodified > lastsync: gtdFolder mit daten aus remoteFolder.localFolder überschreiben
 wenn lastmodified <= lastsync: localFolder mit gtdFolder überschreiben
 
 3b wenn ich keinen passenden gtdFolder finde und remoteFolder.localFolder.deletedByApp != true: neuen gtdFolder anlegen
 sonst wenn lastmodified <= lastsync dann bedeuted das, dass der folder in toodledo gelöscht wurde daher: remoteFolder deleten.
 
 4 jetzt die übriggebliebenen gtdFolders hernehmen und für jeden einen remoteFolder + remoteFolder.localFolder anlegen
 
 bei den anderen wird es fast ident sein. nur bei tasks und notes kommt der fall dazu, dass zb gtdTask.lastEdit auch > lastSync ist und dann der user gepromptet werden muss.
 */

@end

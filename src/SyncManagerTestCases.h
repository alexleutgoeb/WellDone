//
//  SyncManagerTestCases.h
//  WellDone
//
//  Created by Michael Petritsch on 27.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "GtdApi.h"
#import "SyncController.h"
#import "SyncManager.h"

@interface SyncManagerTestCases : SenTestCase {
	// Data model support
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	SyncController *sc;
	SyncManager *sm;
	id<GtdApi> api;	
	//TDSimpleParser *simpleParser;
	//TDFoldersParser *folderParser;
}

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

/**
 init db for tests
 */
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator;

- (NSManagedObjectContext *) managedObjectContext;

- (NSManagedObjectModel *)managedObjectModel;

- (NSString *)applicationSupportDirectory;

//Folder tests

/**
 if modifiedDate of localFolder greater than lastsyncDate of remoteFolder
 then overwrite GtdFolder Data with localFolder data
 */
-(void)FolderSyncWithLocalModifiedDateGreaterLastSync;

/**
 if modifiedDate of localFolder less or equal lastsyncDate of remoteFolder
 then overwrite localFolder Data with GtdFolder data
 */
-(void)FolderSyncWithLocalModifiedDateLessOrEqualLastSync;

/**
 if a new folder got created locally
 then create it remotely
 */
-(void)FolderCreatedLocal;

/**
 if a new folder got created remotely
 then create it locally
 */
-(void)FolderCreatedRemote;

/**
 if a folder got deleted locally
 then delete it remotely
 */
-(void)FolderDeletedLocal;

/**
 if a folder got deleted remotely
 then delete it locally
 */
-(void)FolderDeletedRemote;


//Context tests

/**
 if modifiedDate of localContext greater than lastsyncDate of remoteContext
 then overwrite GtdContext Data with localContext data
 */
-(void)ContextSyncWithLocalModifiedDateGreaterLastSync;

/**
 if modifiedDate of localContext less or equal lastsyncDate of remoteContext
 then overwrite localContext Data with GtdContext data
 */
-(void)ContextSyncWithLocalModifiedDateLessOrEqualLastSync;

/**
 if new context got created locally
 then create it remotely
 */
-(void)ContextCreatedLocal;

/**
 if new context got created remotely
 then create it locally
 */
-(void)ContextCreatedRemote;

/**
 if context got deleted locally
 then delete it remotely
 */
-(void)ContextDeletedLocal;

/**
 if context got deleted remotely
 then delete it locally
 */
-(void)ContextDeletedRemote;


//Note tests

/**
 if (modifiedDate of localNote) > lastsyncDate of remoteNote >= (date_modified of gtdNote)
 then overwrite GtdNote data with localNote data
 */
-(void)NoteSyncWithLocalModifiedDateGreaterLastSyncGreaterOrEqualRemoteDate_Modified;

/**
 if (modifiedDate of localNote) <= lastsyncDate of remoteNote >= (date_modified of gtdNote)
 then do not change localNote data or gtdNote data
 */
-(void)NoteSyncWithLocalAndRemoteDatesLessOrEqualLastSync;

/**
 if (modifiedDate of localNote) <= lastsyncDate of remoteNote < (date_modified of gtdNote)
 then overwrite localNote data with gtdNote data
 */
-(void)NoteSyncWithLocalModifiedDateLessOrEqualLastSyncLessRemoteDateModified;

/**
 if (modifiedDate of localNote) > lastsyncDate of remoteNote < (date_modified of gtdNote)
 then let the user decide
 */
-(void)NoteSyncWithLocalAndRemoteGreaterLastSync;

/**
 if a new note got created locally
 then create it remotely
 */
-(void)NoteCreatedLocal;

/**
 if a new note got created remotely
 then create it locally
 */
-(void)NoteCreatedRemote;

/**
 if a note got deleted locally
 then delete it remotely
 */
-(void)NoteDeletedLocal;

/**
 if a note got deleted remotely
 then delete it locally
 */
-(void)NoteDeletedRemote;


//Task tests

/**
 if (modifiedDate of localTask) > lastsyncDate of remoteTask >= (date_modified of gtdTask)
 then overwrite gtdTask data with localTask data
 */
-(void)TaskSyncWithLocalModifiedDateGreaterLastSyncGreaterOrEqualRemoteDate_Modified;

/**
 if (modifiedDate of localTask) <= lastsyncDate of remoteTask >= (date_modified of gtdTask)
 then do not change localTask data or gtdTask data
 */
-(void)TaskSyncWithLocalAndRemoteDatesLessOrEqualLastSync;

/**
 if (modifiedDate of localTask) <= lastsyncDate of remoteTask < (date_modified of gtdTask)
 then overwrite localNote data with gtdNote data
 */
-(void)TaskSyncWithLocalModifiedDateLessOrEqualLastSyncLessRemoteDateModified;

/**
 if (modifiedDate of localTask) > lastsyncDate of remoteTask < (date_modified of gtdTask)
 then let the user decide
 */
-(void)TaskSyncWithLocalAndRemoteGreaterLastSync;

/**
 if a new task got created locally
 then create it remotely
 */
-(void)TaskCreatedLocal;

/**
 if a new task got created remotely
 then create it locally
 */
-(void)TaskCreatedRemote;

/**
 if a task got deleted locally
 then delete it remotely
 */
-(void)TaskDeletedLocal;

/**
 if a task got deleted remotely
 then delete it locally
 */
-(void)TaskDeletedRemote;

@end

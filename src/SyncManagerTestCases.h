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
-(void)testFolderSyncWithLocalModifiedDateGreaterLastSync;

/**
 if modifiedDate of localFolder less or equal lastsyncDate of remoteFolder
 then overwrite localFolder Data with GtdFolder data
 */
-(void)testFolderSyncWithLocalModifiedDateLessOrEqualLastSync;

/**
 if a new folder got created locally
 then create it remotely
 */
-(void)testFolderCreatedLocal;

/**
 if a new folder got created remotely
 then create it locally
 */
-(void)testFolderCreatedRemote;

/**
 if a folder got deleted locally
 then delete it remotely
 */
-(void)testFolderDeletedLocal;

/**
 if a folder got deleted remotely
 then delete it locally
 */
-(void)testFolderDeletedRemote;


//Context tests

/**
 if modifiedDate of localContext greater than lastsyncDate of remoteContext
 then overwrite GtdContext Data with localContext data
 */
-(void)testContextSyncWithLocalModifiedDateGreaterLastSync;

/**
 if modifiedDate of localContext less or equal lastsyncDate of remoteContext
 then overwrite localContext Data with GtdContext data
 */
-(void)testContextSyncWithLocalModifiedDateLessOrEqualLastSync;

/**
 if new context got created locally
 then create it remotely
 */
-(void)testContextCreatedLocal;

/**
 if new context got created remotely
 then create it locally
 */
-(void)testContextCreatedRemote;

/**
 if context got deleted locally
 then delete it remotely
 */
-(void)testContextDeletedLocal;

/**
 if context got deleted remotely
 then delete it locally
 */
-(void)testContextDeletedRemote;


//Note tests

/**
 if (modifiedDate of localNote) > lastsyncDate of remoteNote >= (date_modified of gtdNote)
 then overwrite GtdNote data with localNote data
 */
-(void)testNoteSyncWithLocalModifiedDateGreaterLastSyncGreaterOrEqualRemoteDate_Modified;

/**
 if (modifiedDate of localNote) <= lastsyncDate of remoteNote >= (date_modified of gtdNote)
 then do not change localNote data or gtdNote data
 */
-(void)testNoteSyncWithLocalAndRemoteDatesLessOrEqualLastSync;

/**
 if (modifiedDate of localNote) <= lastsyncDate of remoteNote < (date_modified of gtdNote)
 then overwrite localNote data with gtdNote data
 */
-(void)testNoteSyncWithLocalModifiedDateLessOrEqualLastSyncLessRemoteDateModified;

/**
 if (modifiedDate of localNote) > lastsyncDate of remoteNote < (date_modified of gtdNote)
 then let the user decide
 */
-(void)testNoteSyncWithLocalAndRemoteGreaterLastSync;

/**
 if a new note got created locally
 then create it remotely
 */
-(void)testNoteCreatedLocal;

/**
 if a new note got created remotely
 then create it locally
 */
-(void)testNoteCreatedRemote;

/**
 if a note got deleted locally
 then delete it remotely
 */
-(void)testNoteDeletedLocal;

/**
 if a note got deleted remotely
 then delete it locally
 */
-(void)testNoteDeletedRemote;


//Task tests

/**
 if (modifiedDate of localTask) > lastsyncDate of remoteTask >= (date_modified of gtdTask)
 then overwrite gtdTask data with localTask data
 */
-(void)testTaskSyncWithLocalModifiedDateGreaterLastSyncGreaterOrEqualRemoteDate_Modified;

/**
 if (modifiedDate of localTask) <= lastsyncDate of remoteTask >= (date_modified of gtdTask)
 then do not change localTask data or gtdTask data
 */
-(void)testTaskSyncWithLocalAndRemoteDatesLessOrEqualLastSync;

/**
 if (modifiedDate of localTask) <= lastsyncDate of remoteTask < (date_modified of gtdTask)
 then overwrite localNote data with gtdNote data
 */
-(void)testTaskSyncWithLocalModifiedDateLessOrEqualLastSyncLessRemoteDateModified;

/**
 if (modifiedDate of localTask) > lastsyncDate of remoteTask < (date_modified of gtdTask)
 then let the user decide
 */
-(void)testTaskSyncWithLocalAndRemoteGreaterLastSync;

/**
 if a new task got created locally
 then create it remotely
 */
-(void)testTaskCreatedLocal;

/**
 if a new task got created remotely
 then create it locally
 */
-(void)testTaskCreatedRemote;

/**
 if a task got deleted locally
 then delete it remotely
 */
-(void)testTaskDeletedLocal;

/**
 if a task got deleted remotely
 then delete it locally
 */
-(void)testTaskDeletedRemote;

@end

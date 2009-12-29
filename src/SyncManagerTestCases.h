//
//  SyncManagerTestCases.h
//  WellDone
//
//  Created by Michael Petritsch on 27.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@interface SyncManagerTestCases : SenTestCase {
	
}

//Folder tests

/**
 Test:
 Wenn modifiedDate des lokalen Folders größer ist als LastSync
 dann sollten die daten des lokalen Folders nach dem sync remote übernommen worden sein
 */
-(void)FolderSyncWithLocalModifiedDateGreaterLastSync;

/**
 Test:
 Wenn modifiedDate des lokalen Folders kleiner oder gleich LastSync
 dann sollten die Daten des remote Folders nach dem sync lokal übernommen worden sein
 */
-(void)FolderSyncWithLocalModifiedDateLessOrEqualLastSync;

/**
 Test:
 Wenn neuer Folder lokal angelegt wurde
 dann sollte dieser nach dem sync auch remote vorhanden sein
 */
-(void)FolderCreatedLocal;

/**
 Test:
 Wenn neuer Folder remote angelegt wurde
 dann sollte dieser nach dem sync auch lokal vorhanden sein
 */
-(void)FolderCreatedRemote;

/**
 Test:
 Wenn Folder lokal gelöscht wurde
 dann sollte dieser nach dem sync auch remote gelöscht sein
 */
-(void)FolderDeleteLocal;

/**
 Test:
 Wenn Folder remote gelöscht wurde
 dann sollte dieser nach dem sync auch lokal gelöscht sein
 */
-(void)FolderDeleteRemote;


//Context tests

/**
 Test:
 Wenn modifiedDate des lokalen Context größer ist als LastSync
 dann sollten die Daten des lokalen Context nach dem sync remote übernommen sein
 */
-(void)ContextSyncWithLocalModifiedDateGreaterLastSync;

/**
 Test:
 Wenn modifiedDate des lokalen Context kleiner oder gleich LastSync
 dann sollten die Daten des remote Context nach dem sync lokal übernommen sein
 */
-(void)ContextSyncWithLocalModifiedDateLessOrEqualLastSync;

/**
 Test:
 Wenn neuer Context lokal angelegt wurde
 dann sollte dieser nach dem sync remote angelegt sein
 */
-(void)ContextCreatedLocal;

/**
 Test:
 Wenn neuer Context remote angelegt wurde
 dann sollte dieser nach dem sync lokal angelegt sein
 */
-(void)ContextCreatedRemote;

/**
 Test:
 Wenn Context lokal gelöscht wurde
 dann sollte dieser nach dem sync auch remote gelöscht sein
 */
-(void)ContextDeleteLocal;

/**
 Test:
 Wenn Context remote gelöscht wurde
 dann sollte dieser nach dem sync auch lokal gelöscht sein
 */
-(void)ContextDeleteRemote;


//Note tests

/**
 Test:
 Wenn (modifiedDate der lokalen Note) > lastSync >= (date_modified der remote Note)
 dann sollten die Daten der lokalen Note nach dem Sync remote übernommen sein
 */
-(void)NoteSyncWithLocalModifiedDateGreaterLastSyncGreaterOrEqualRemoteDate_Modified;

/**
 Test:
 Wenn (modifiedDate der lokalen Note) <= lastSync >= (date_modified der remote Note)
 dann sollen die Daten sowohl remote als auch lokal unverändert bleiben
 */
-(void)NoteSyncWithLocalAndRemoteDatesLessOrEqualLastSync;

/**
 Test:
 Wenn (modifiedDate der lokalen Note) <= lastSync < (date_modified der remote Note)
 dann sollen die Daten der remote Note nach dem Sync lokal übernommen sein
 */
-(void)NoteSyncWithLocalModifiedDateLessOrEqualLastSyncLessRemoteDateModified;

/**
 Test:
 Wenn (modifiedDate der lokalen Note) > lastSync < (date_modified der remote Note)
 dann soll der User entscheiden was übernommen wird
 */
-(void)NoteSyncWithLocalAndRemoteGreaterLastSync;

/**
 Test:
 Wenn neue Note lokal angelegt wurde
 dann sollte diese nach dem sync remote angelegt sein
 */
-(void)NoteCreatedLocal;

/**
 Test:
 Wenn neue Note remote angelegt wurde
 dann sollte diese nach dem sync lokal angelegt sein
 */
-(void)NoteCreatedRemote;

/**
 Test:
 Wenn Note lokal gelöscht wurde
 dann sollte diese nach dem sync auch remote gelöscht sein
 */
-(void)NoteDeleteLocal;

/**
 Test:
 Wenn Note remote gelöscht wurde
 dann sollte diese nach dem sync auch lokal gelöscht sein
 */
-(void)NoteDeleteRemote;


//Task tests

/**
 Test:
 Wenn (modifiedDate des lokalen Task) > lastSync >= (date_modified des remote Task)
 dann sollten die Daten der lokalen Note nach dem Sync remote übernommen sein
 */
-(void)TaskSyncWithLocalModifiedDateGreaterLastSyncGreaterOrEqualRemoteDate_Modified;

/**
 Test:
 Wenn (modifiedDate des lokalen Task) <= lastSync >= (date_modified des remote Task)
 dann sollen die Daten sowohl remote als auch lokal unverändert bleiben
 */
-(void)TaskSyncWithLocalAndRemoteDatesLessOrEqualLastSync;

/**
 Test:
 Wenn (modifiedDate des lokalen Task) <= lastSync < (date_modified des remote Task)
 dann sollen die Daten der remote Task nach dem Sync lokal übernommen sein
 */
-(void)TaskSyncWithLocalModifiedDateLessOrEqualLastSyncLessRemoteDateModified;

/**
 Test:
 Wenn (modifiedDate des lokalen Task) > lastSync < (date_modified des remote Task)
 dann soll der User entscheiden was übernommen wird
 */
-(void)TaskSyncWithLocalAndRemoteGreaterLastSync;

/**
 Test:
 Wenn neuer Task lokal angelegt wurde
 dann sollte dieser nach dem sync remote angelegt sein
 */
-(void)TaskCreatedLocal;

/**
 Test:
 Wenn neuer Task remote angelegt wurde
 dann sollte dieser nach dem sync lokal angelegt sein
 */
-(void)TaskCreatedRemote;

/**
 Test:
 Wenn Task lokal gelöscht wurde
 dann sollte dieser nach dem sync auch remote gelöscht sein
 */
-(void)TaskDeleteLocal;

/**
 Test:
 Wenn Task remote gelöscht wurde
 dann sollte dieser nach dem sync auch lokal gelöscht sein
 */
-(void)TaskDeleteRemote;

@end

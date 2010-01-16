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
#import "RemoteContext.h"
#import "RemoteTask.h"
#import "Note.h"
#import "Task.h"
#import "Tag.h"
#import "Context.h"
#import "TaskContainer.h"
#import "WDNSSet+subset.h"


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

- (NSManagedObjectContext *)syncData:(NSManagedObjectContext *)aManagedObjectContext conflicts:(NSArray **)conflicts {
	// TODO: implement
	
	if ([syncServices count] > 0) {
		
		// Take only the first sync service from the list
		id<GtdApi> syncService = [syncServices objectForKey:[[syncServices allKeys] objectAtIndex:0]];
		
		// last edited dates
		//NSDictionary *lastDates = [syncService getLastModificationsDates:&error];
		
		
		aManagedObjectContext = [self syncFolders:aManagedObjectContext withSyncService:syncService];
		aManagedObjectContext = [self syncContexts:aManagedObjectContext withSyncService:syncService];
		//aManagedObjectContext = [self syncTasks:aManagedObjectContext withSyncService:syncService andConflicts:*&conflicts];
								 
		/*if (lastDates != nil && error == nil) {
				
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
		}*/
		
		return aManagedObjectContext;
	}
	else {
		// no sync service registered, return nil
		return nil;
	}
}

- (NSManagedObjectContext *)replaceLocalData:(NSManagedObjectContext *)aManagedObjectContext {

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

/**
 generische variante zum erstellen von remoteObjects
 
 @author: Michael
 
*/
/*- (void) checkAndCreateRemoteObjects:(NSArray *) remoteObjects withObjectName: (NSString) objectName fromObjectContext: (NSManagedObjectContext *) aManagedObjectContext {
	
	NSError *error = nil;
	
	//zuerst alle remoteFolders erstellen falls sie noch nicht existieren
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:objectName inManagedObjectContext:aManagedObjectContext];
	[fetchRequest setEntity:entity];
	NSArray *localObjects = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	
	BOOL foundRemoteObject;
	//lokale Objekte nach remoteObjekten durchsuchen und gegebenenfalls adden
	for (NSManagedObject *localObject in localObjects) {
		
		foundRemoteObject = NO;
		NSEnumerator *enumerator = [localObject.remoteObjects objectEnumerator];
		
		RemoteObject *remoteObject = nil;
		
		while ((remoteObject = [enumerator nextObject])) {
			//wenn remoteobject existiert
			if(remoteObject.serviceIdentifier == syncService.identifier) foundRemoteObject = YES;
		}
		
		if(foundRemoteObject == NO) {
			//create Remotefolder
			RemoteObject ro = createRemoteObject(objectName, localObject);
		}
	}
}*/

/**
 Folder sync
 @author Michael
 */
- (NSManagedObjectContext *) syncFolders:(NSManagedObjectContext *) aManagedObjectContext withSyncService: (id<GtdApi>) syncService {
	
	NSError *error = nil;
	
	//zuerst alle remoteFolders erstellen falls sie noch nicht existieren
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:aManagedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSArray *localFolders = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	/*entity = [NSEntityDescription entityForName:@"RemoteFolder" inManagedObjectContext:aManagedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSArray *remoteFolders = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];*/
	[fetchRequest release];
	
	//now find a corresponding GTDfolder
	NSMutableArray *gtdFolders = (NSMutableArray *) [syncService getFolders:&error];
	NSMutableArray *foundGtdFolders = [[NSMutableArray alloc] init];
	GtdFolder *foundGtdFolder;
	RemoteFolder *remoteFolder;
	DLog(@"xxxxxxxxxxxxx    schleifenbeginn    xxxxxxxxxxxx ");
	//lokale Objekte nach remoteObjekten durchsuchen und gegebenenfalls adden
	for (Folder *localFolder in localFolders) {
		DLog(@"localFolder.name %@", localFolder.name);
		//[aManagedObjectContext deleteObject:localFolder];
		NSEnumerator *enumerator = [localFolder.remoteFolders objectEnumerator];
		DLog(@"localFolder.remoteFolder %@", [localFolder.remoteFolders description]);
		remoteFolder = nil;
		
		while ((remoteFolder = [enumerator nextObject])) {
			//wenn remoteobject existiert
			if([remoteFolder.serviceIdentifier isEqualToString:syncService.identifier]) break;
			else remoteFolder = nil;
		}
		//now we can safely assume, that each local folder has a remoteFolder
		//no remoteFolder was found, create one
		if(remoteFolder == nil) {
			DLog(@"creating remoteFolder for folder %@", localFolder.name);
			remoteFolder = [NSEntityDescription insertNewObjectForEntityForName:@"RemoteFolder" inManagedObjectContext:aManagedObjectContext];
			remoteFolder.serviceIdentifier = syncService.identifier;
			remoteFolder.remoteUid = [NSNumber numberWithInteger:-1];
			remoteFolder.lastsyncDate = nil;
			remoteFolder.localFolder = localFolder;
			NSMutableSet *mutableRemoteFolders = [localFolder mutableSetValueForKey:@"remoteFolders"];
			[mutableRemoteFolders addObject:remoteFolder];
			DLog(@"syncFolder addFolder.");
			GtdFolder *newGtdFolder = [[GtdFolder alloc] init];
			newGtdFolder.title = localFolder.name;
			if([localFolder.private intValue] == 1)
				newGtdFolder.private = YES;
			else newGtdFolder.private = NO;
			//newGtdFolder.archived = localFolder.archived;
			//newGtdFolder.order = [localFolder.order integerValue];
			remoteFolder.remoteUid = [NSNumber numberWithLong:[syncService addFolder:newGtdFolder error:&error]];
			DLog(@"new remoteUid: %@", remoteFolder.remoteUid);
			remoteFolder.lastsyncDate = [NSDate date];
			newGtdFolder.uid = [remoteFolder.remoteUid integerValue];
			foundGtdFolder = newGtdFolder;
		} else {
			//find gtdfolder
			foundGtdFolder = nil;
			for(GtdFolder *gtdFolder in gtdFolders) {
				DLog(@"found GtdFolder %@", gtdFolder.title);
				DLog(@"gtdFolder.uid %i", gtdFolder.uid);
				DLog(@"remoteFolder.remoteUid %@", remoteFolder.remoteUid);
				if(gtdFolder.uid == [remoteFolder.remoteUid integerValue]) {
					DLog(@"syncFolder matching remoteUid. %i", gtdFolder.uid);
					[foundGtdFolders addObject:gtdFolder];
					foundGtdFolder = gtdFolder;
					break;
				}
			}
			for(GtdFolder *bla in foundGtdFolders) {
				DLog(@"syncFolder foundFolder. %@", bla.title);
			}
		}
		
		DLog(@"localFolder.modifiedDate: %@", localFolder.modifiedDate);
		DLog(@"remoteFolder.lastsyncDate: %@", remoteFolder.lastsyncDate);
		DLog(@"localFolder.deletedByApp: %@", localFolder.deletedByApp);
		
		//DLog(@"localFolder.modifiedDate: %@", localFolder.modifiedDate);
		if([localFolder.deletedByApp integerValue] == 1) {
			DLog(@"syncFolder deleting a folder.");
			if(foundGtdFolder != nil)
				[syncService deleteFolder:foundGtdFolder error:&error];
			[aManagedObjectContext deleteObject:localFolder];
		} else if(foundGtdFolder == nil) {
			DLog(@"syncFolder deleting cos no foundGtdFolder");
			if(remoteFolder.lastsyncDate != nil && [remoteFolder.lastsyncDate timeIntervalSinceDate:localFolder.modifiedDate] > 0) {
				[aManagedObjectContext deleteObject:localFolder];
			}
		
		} else if([localFolder.modifiedDate timeIntervalSinceDate:remoteFolder.lastsyncDate] < 0) {
			DLog(@"syncFolder writing data to local.");
			DLog(@"timedifference: %i", [localFolder.modifiedDate timeIntervalSinceDate:remoteFolder.lastsyncDate]);
			localFolder.name = foundGtdFolder.title;
			if(foundGtdFolder.private == YES) localFolder.private = [NSNumber numberWithInt:1];
			else localFolder.private = [NSNumber numberWithInt:0];
			localFolder.order = [NSNumber numberWithInt:foundGtdFolder.order];
			remoteFolder.lastsyncDate = [NSDate date];
		} else {
			//editFolder
			DLog(@"syncFolder editFolder.");
			DLog(@"timedifference: %i", [localFolder.modifiedDate timeIntervalSinceDate:remoteFolder.lastsyncDate]);
			GtdFolder *newGtdFolder = [[GtdFolder alloc] init];
			newGtdFolder.uid = [remoteFolder.remoteUid integerValue];
			DLog(@"check.");
			newGtdFolder.title = localFolder.name;
			if([localFolder.private intValue] == 1)
				newGtdFolder.private = YES;
			else newGtdFolder.private = NO;
			//newGtdFolder.archived = localFolder.archived;
			//newGtdFolder.order = [localFolder.order integerValue];
			DLog(@"check2.");
			//overwrite the remote remoteFolder with the local folder
			[syncService editFolder:newGtdFolder error:&error];
			DLog(@"check3.");
			remoteFolder.lastsyncDate = [NSDate date];
		}
		DLog(@"error %@", [error description]);
	}
	//NSMutableArray thxObjC = new NSMutableArray(gtdFolders);
	//finally durchlaufe die gtdFolder die nicht zuordenbar waren und erzeuge sie lokal
	[gtdFolders removeObjectsInArray:foundGtdFolders];
	for(GtdFolder *gtdFolder in gtdFolders) {
		// Add new entities
		RemoteFolder *rFolder = [NSEntityDescription insertNewObjectForEntityForName:@"RemoteFolder" inManagedObjectContext:aManagedObjectContext];
		Folder *lFolder = [NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:aManagedObjectContext];
		
		DLog(@"syncFolder adding new folder to local.");
		
		// Set entity attributes
		rFolder.serviceIdentifier = syncService.identifier;
		rFolder.remoteUid = [NSNumber numberWithInteger:gtdFolder.uid];
		rFolder.lastsyncDate = [NSDate date];
		rFolder.localFolder = lFolder;
		lFolder.name = gtdFolder.title;
		lFolder.private = [NSNumber numberWithBool:gtdFolder.private];
		lFolder.order = [NSNumber numberWithInteger:gtdFolder.order];
		NSMutableSet *mutableRemoteFolders = [lFolder mutableSetValueForKey:@"remoteFolders"];
		[mutableRemoteFolders addObject:rFolder];
	}
		
	//zuerst innerhalb einer passenden datenstruktur jedem element aus rFolder das entsprechende element aus gtdFolder zuordnen
		//falls es zu einem rFolder element keinen gtdFolder gibt:
			//wenn rFolder.localFolder.deletedByApp != true -> [syncService addFolder]
		//falls unzugeordnete gtdfolder übrigbleiben -> neue folder lokal anlegen und gleich daten übernehmen
	return aManagedObjectContext;
}


/**
 Context sync
 @author Michael
 */
- (NSManagedObjectContext *) syncContexts:(NSManagedObjectContext *) aManagedObjectContext withSyncService: (id<GtdApi>) syncService {
	
	NSError *error = nil;
	
	//zuerst alle remoteContexts erstellen falls sie noch nicht existieren
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Context" inManagedObjectContext:aManagedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSArray *localContexts = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	/*entity = [NSEntityDescription entityForName:@"RemoteContext" inManagedObjectContext:aManagedObjectContext];
	 [fetchRequest setEntity:entity];
	 
	 NSArray *remoteContexts = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];*/
	[fetchRequest release];
	
	//now find a corresponding GTDcontext
	NSMutableArray *gtdContexts = (NSMutableArray *) [syncService getContexts:&error];
	NSMutableArray *foundGtdContexts = [[NSMutableArray alloc] init];
	GtdContext *foundGtdContext;
	RemoteContext *remoteContext;
	DLog(@"xxxxxxxxxxxxx    schleifenbeginn    xxxxxxxxxxxx ");
	//lokale Objekte nach remoteObjekten durchsuchen und gegebenenfalls adden
	for (Context *localContext in localContexts) {
		DLog(@"localContext.title %@", localContext.title);
		//[aManagedObjectContext deleteObject:localContext];
		NSEnumerator *enumerator = [localContext.remoteContexts objectEnumerator];
		DLog(@"localContext.remoteContext %@", [localContext.remoteContexts description]);
		remoteContext = nil;
		
		while ((remoteContext = [enumerator nextObject])) {
			//wenn remoteobject existiert
			if([remoteContext.serviceIdentifier isEqualToString:syncService.identifier]) break;
			else remoteContext = nil;
		}
		//now we can safely assume, that each local context has a remoteContext
		//no remoteContext was found, create one
		if(remoteContext == nil) {
			DLog(@"creating remoteContext for context %@", localContext.title);
			remoteContext = [NSEntityDescription insertNewObjectForEntityForName:@"RemoteContext" inManagedObjectContext:aManagedObjectContext];
			remoteContext.serviceIdentifier = syncService.identifier;
			remoteContext.remoteUid = [NSNumber numberWithInteger:-1];
			remoteContext.lastsyncDate = nil;
			remoteContext.localContext = localContext;
			NSMutableSet *mutableRemoteContexts = [localContext mutableSetValueForKey:@"remoteContexts"];
			[mutableRemoteContexts addObject:remoteContext];
			DLog(@"syncContext addContext.");
			GtdContext *newGtdContext = [[GtdContext alloc] init];
			newGtdContext.title = localContext.title;

			remoteContext.remoteUid = [NSNumber numberWithLong:[syncService addContext:newGtdContext error:&error]];
			DLog(@"new remoteUid: %@", remoteContext.remoteUid);
			remoteContext.lastsyncDate = [NSDate date];
			newGtdContext.uid = [remoteContext.remoteUid integerValue];
			foundGtdContext = newGtdContext;
		} else {
			//find gtdcontext
			foundGtdContext = nil;
			for(GtdContext *gtdContext in gtdContexts) {
				DLog(@"found GtdContext %@", gtdContext.title);
				DLog(@"gtdContext.uid %i", gtdContext.uid);
				DLog(@"remoteContext.remoteUid %@", remoteContext.remoteUid);
				if(gtdContext.uid == [remoteContext.remoteUid integerValue]) {
					DLog(@"syncContext matching remoteUid. %i", gtdContext.uid);
					[foundGtdContexts addObject:gtdContext];
					foundGtdContext = gtdContext;
					break;
				}
			}
			for(GtdContext *bla in foundGtdContexts) {
				DLog(@"syncContext foundContext. %@", bla.title);
			}
		}
		
		DLog(@"localContext.modifiedDate: %@", localContext.modifiedDate);
		DLog(@"remoteContext.lastsyncDate: %@", remoteContext.lastsyncDate);
		DLog(@"localContext.deletedByApp: %@", localContext.deletedByApp);
		
		//DLog(@"localContext.modifiedDate: %@", localContext.modifiedDate);
		if([localContext.deletedByApp integerValue] == 1) {
			DLog(@"syncContext deleting a context.");
			if(foundGtdContext != nil)
				[syncService deleteContext:foundGtdContext error:&error];
			[aManagedObjectContext deleteObject:localContext];
		} else if(foundGtdContext == nil) {
			DLog(@"syncContext deleting cos no foundGtdContext");
			if(remoteContext.lastsyncDate != nil && [remoteContext.lastsyncDate timeIntervalSinceDate:localContext.modifiedDate] > 0) {
				[aManagedObjectContext deleteObject:localContext];
			}
			
		} else if ([localContext.modifiedDate timeIntervalSinceDate:remoteContext.lastsyncDate] == 0) {
			DLog(@"XXXXXXXXXXXXXXXXXXX MODIFIEDDATE EQUAL LASTSYNCDATE MOTHERFUCKER *ÜXXXXXXXXXXXX");
		} else if([localContext.modifiedDate timeIntervalSinceDate:remoteContext.lastsyncDate] < 0) {
			DLog(@"syncContext writing data to local.");
			DLog(@"timedifference: %i", [localContext.modifiedDate timeIntervalSinceDate:remoteContext.lastsyncDate]);
			localContext.title = foundGtdContext.title;
			remoteContext.lastsyncDate = [NSDate date];
		} else {
			//editContext
			DLog(@"syncContext editContext.");
			DLog(@"timedifference: %i", [localContext.modifiedDate timeIntervalSinceDate:remoteContext.lastsyncDate]);
			GtdContext *newGtdContext = [[GtdContext alloc] init];
			newGtdContext.uid = [remoteContext.remoteUid integerValue];
			DLog(@"check.");
			newGtdContext.title = localContext.title;
			DLog(@"check2.");
			//overwrite the remote remoteContext with the local context
			[syncService editContext:newGtdContext error:&error];
			DLog(@"check3.");
			remoteContext.lastsyncDate = [NSDate date];
		}
		DLog(@"error %@", [error description]);
	}
	//NSMutableArray thxObjC = new NSMutableArray(gtdContexts);
	//finally durchlaufe die gtdContext die nicht zuordenbar waren und erzeuge sie lokal
	[gtdContexts removeObjectsInArray:foundGtdContexts];
	for(GtdContext *gtdContext in gtdContexts) {
		// Add new entities
		RemoteContext *rContext = [NSEntityDescription insertNewObjectForEntityForName:@"RemoteContext" inManagedObjectContext:aManagedObjectContext];
		Context *lContext = [NSEntityDescription insertNewObjectForEntityForName:@"Context" inManagedObjectContext:aManagedObjectContext];
		
		DLog(@"syncContext adding new context to local.");
		
		// Set entity attributes
		rContext.serviceIdentifier = syncService.identifier;
		rContext.remoteUid = [NSNumber numberWithInteger:gtdContext.uid];
		rContext.lastsyncDate = [NSDate date];
		rContext.localContext = lContext;
		lContext.title = gtdContext.title;		
		NSMutableSet *mutableRemoteContexts = [lContext mutableSetValueForKey:@"remoteContexts"];
		[mutableRemoteContexts addObject:rContext];
	}
	
	//zuerst innerhalb einer passenden datenstruktur jedem element aus rContext das entsprechende element aus gtdContext zuordnen
	//falls es zu einem rContext element keinen gtdContext gibt:
	//wenn rContext.localContext.deletedByApp != true -> [syncService addContext]
	//falls unzugeordnete gtdcontext übrigbleiben -> neue context lokal anlegen und gleich daten übernehmen
	return aManagedObjectContext;
}


/**
 Task sync
 @author Michael
 */
- (NSManagedObjectContext *)syncTasks:(NSManagedObjectContext *)aManagedObjectContext withSyncService:(id<GtdApi>)syncService andConflicts:(NSArray **)conflicts {
	
	NSError *error = nil;
	NSMutableDictionary *possibleTags = [NSMutableDictionary dictionary];
	
	// Load all possible tags in a dictionary named possibleTags
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:aManagedObjectContext];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deletedByApp == %@", [NSNumber numberWithInt:0]];
	[fetchRequest setPredicate:predicate];
	NSArray *allTags = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if (allTags != nil && error == nil) {
		// Save in dictionary
		for (Tag *t in allTags) {
			[possibleTags setObject:t forKey:[t description]];
		}
	}
	else {
		DLog(@"Error while retrieving all tags, cancelling...");
		return nil;
	}
	
	//zuerst alle remoteTasks erstellen falls sie noch nicht existieren
	fetchRequest = [[NSFetchRequest alloc] init];
	entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:aManagedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSArray *localTasks = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
	//now find a corresponding GTDfolder
	NSMutableArray *gtdTasks = (NSMutableArray *) [syncService getTasks:&error];
	NSMutableArray *foundGtdTasks = [[NSMutableArray alloc] init];
	NSMutableArray *actualConflicts = [[NSMutableArray alloc] init];
	GtdTask *foundGtdTask;
	RemoteTask *remoteTask;
	DLog(@"xxxxxxxxxxxxx    schleifenbeginn    xxxxxxxxxxxx ");
	//lokale Objekte nach remoteObjekten durchsuchen und gegebenenfalls adden
	for (Task *localTask in localTasks) {
		DLog(@"localTask.name %@", localTask.title);
		//[aManagedObjectContext deleteObject:localTask];
		NSEnumerator *enumerator = [localTask.remoteTasks objectEnumerator];
		DLog(@"localTask.remoteTask %@", [localTask.remoteTasks description]);
		remoteTask = nil;
		
		while ((remoteTask = [enumerator nextObject])) {
			//wenn remoteobject existiert
			if([remoteTask.serviceIdentifier isEqualToString:syncService.identifier]) break;
			else remoteTask = nil;
		}
		//now we can safely assume, that each local folder has a remoteTask
		//no remoteTask was found, create one
		if(remoteTask == nil) {
			DLog(@"creating remoteTask for folder %@", localTask.title);
			remoteTask = [NSEntityDescription insertNewObjectForEntityForName:@"RemoteTask" inManagedObjectContext:aManagedObjectContext];
			remoteTask.serviceIdentifier = syncService.identifier;
			remoteTask.remoteUid = [NSNumber numberWithInteger:-1];
			remoteTask.lastsyncDate = nil;
			remoteTask.localTask = localTask;
			NSMutableSet *mutableRemoteTasks = [localTask mutableSetValueForKey:@"remoteTasks"];
			[mutableRemoteTasks addObject:remoteTask];
			DLog(@"syncTask addTask.");

			GtdTask *newGtdTask = [[GtdTask alloc] init];
			newGtdTask.title = localTask.title;
			newGtdTask.uid = 0;
			if ([localTask.tags count] > 0)
				newGtdTask.tags = [[localTask.tags valueForKey:@"text"] allObjects];
			//newGtdTask.archived = localTask.archived;
			//newGtdTask.order = [localTask.order integerValue];
			
			remoteTask.remoteUid = [NSNumber numberWithInteger:[syncService addTask:newGtdTask error:&error]];
			DLog(@"new remoteUid: %@", remoteTask.remoteUid);
			remoteTask.lastsyncDate = [NSDate date];
			newGtdTask.uid = [remoteTask.remoteUid integerValue];
			foundGtdTask = newGtdTask;
		} else {
			//find gtdfolder
			foundGtdTask = nil;
			for(GtdTask *gtdTask in gtdTasks) {
				DLog(@"found GtdTask %@", gtdTask.title);
				DLog(@"gtdTask.uid %i", gtdTask.uid);
				DLog(@"remoteTask.remoteUid %@", remoteTask.remoteUid);
				if(gtdTask.uid == [remoteTask.remoteUid integerValue]) {
					DLog(@"syncTask matching remoteUid. %i", gtdTask.uid);
					[foundGtdTasks addObject:gtdTask];
					foundGtdTask = gtdTask;
					break;
				}
			}
			for(GtdTask *bla in foundGtdTasks) {
				DLog(@"syncTask foundTask. %@", bla.title);
			}
		}
		
		DLog(@"localTask.modifiedDate: %@", localTask.modifiedDate);
		DLog(@"remoteTask.lastsyncDate: %@", remoteTask.lastsyncDate);
		DLog(@"localTask.deletedByApp: %@", localTask.deletedByApp);
		
		//DLog(@"localTask.modifiedDate: %@", localTask.modifiedDate);
		if([localTask.deletedByApp integerValue] == 1) {
			DLog(@"syncTask deleting a folder.");
			if(foundGtdTask != nil)
				[syncService deleteTask:foundGtdTask error:&error];
			[aManagedObjectContext deleteObject:localTask];
		} else if(foundGtdTask == nil) {
			DLog(@"syncTask deleting cos no foundGtdTask");
			if(remoteTask.lastsyncDate != nil && [remoteTask.lastsyncDate timeIntervalSinceDate:localTask.modifiedDate] > 0) {
				[aManagedObjectContext deleteObject:localTask];
			}
			
		} else if([localTask.modifiedDate timeIntervalSinceDate:remoteTask.lastsyncDate] > 0 && [foundGtdTask.date_modified timeIntervalSinceDate:remoteTask.lastsyncDate] < 0) {
			//editTask
			DLog(@"syncTask editTask.");
			GtdTask *newGtdTask = [[GtdTask alloc] init];
			newGtdTask.uid = [remoteTask.remoteUid integerValue];
			DLog(@"check.");
			newGtdTask.title = localTask.title;
			newGtdTask.date_created = localTask.createDate;
			newGtdTask.date_modified = localTask.modifiedDate;
			newGtdTask.date_start = localTask.startDate;
			newGtdTask.date_due = localTask.dueDate;			
			newGtdTask.tags = [localTask.tags allObjects];
			
			//ULTRAZACH: finden von remoteUid des folders....
			NSEnumerator *enumerator = [localTask.folder.remoteFolders objectEnumerator];
			RemoteFolder *remoteFolder = nil;
			
			while ((remoteFolder = [enumerator nextObject])) {
				//wenn remoteobject existiert
				if([remoteFolder.serviceIdentifier isEqualToString:syncService.identifier]) break;
				else remoteFolder = nil;
			}
			newGtdTask.folder = [remoteFolder.remoteUid integerValue];
			
			//ULTRAZACH: finden von remoteUid des folders....
			enumerator = [localTask.context.remoteContexts objectEnumerator];
			RemoteContext *remoteContext = nil;
			
			while ((remoteContext = [enumerator nextObject])) {
				//wenn remoteobject existiert
				if([remoteContext.serviceIdentifier isEqualToString:syncService.identifier]) break;
				else remoteContext = nil;
			}
			newGtdTask.context = [remoteContext.remoteUid integerValue];
			newGtdTask.priority = [localTask.priority integerValue];
			if(localTask.completed == [NSNumber numberWithInt:1]) newGtdTask = [NSDate date];
			newGtdTask.length = [localTask.length integerValue];
			newGtdTask.note = localTask.note;
			newGtdTask.star = (localTask.starred == [NSNumber numberWithInt:1] ? YES : NO);
			newGtdTask.repeat = [localTask.repeat integerValue];
			newGtdTask.status = [localTask.status integerValue];
			newGtdTask.reminder = [localTask.reminder integerValue];
			newGtdTask.parentId = [remoteTask.remoteUid intValue];
			
			//overwrite the remote remoteTask with the local folder
			[syncService editTask:newGtdTask error:&error];
			remoteTask.lastsyncDate == [NSDate date];
		} else if([localTask.modifiedDate timeIntervalSinceDate:remoteTask.lastsyncDate] < 0 && [foundGtdTask.date_modified timeIntervalSinceDate:remoteTask.lastsyncDate] > 0) {
			DLog(@"syncTask writing data to local.");
			localTask.title = foundGtdTask.title;
			
			
			
			remoteTask.lastsyncDate == [NSDate date];
		} else if([localTask.modifiedDate timeIntervalSinceDate:remoteTask.lastsyncDate] > 0 && [foundGtdTask.date_modified timeIntervalSinceDate:remoteTask.lastsyncDate] > 0) {
			TaskContainer *tc = [[TaskContainer alloc] init];
			tc.gtdTask = foundGtdTask;
			tc.remoteTask = remoteTask;
			[actualConflicts addObject:tc];
		}
	}
	//NSMutableArray thxObjC = new NSMutableArray(gtdTasks);
	//finally durchlaufe die gtdTask die nicht zuordenbar waren und erzeuge sie lokal
	[gtdTasks removeObjectsInArray:foundGtdTasks];
	for(GtdTask *gtdTask in gtdTasks) {
		// Add new entities
		RemoteTask *rTask = [NSEntityDescription insertNewObjectForEntityForName:@"RemoteTask" inManagedObjectContext:aManagedObjectContext];
		Task *lTask = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:aManagedObjectContext];
		
		DLog(@"syncTask adding new folder to local.");
		
		// Set entity attributes
		rTask.serviceIdentifier = syncService.identifier;
		rTask.remoteUid = [NSNumber numberWithInteger:gtdTask.uid];
		rTask.lastsyncDate = [NSDate date];
		rTask.localTask = lTask;
		lTask.title = gtdTask.title;
		lTask.createDate = gtdTask.date_created;
		lTask.modifiedDate = gtdTask.date_modified;
		lTask.startDate = gtdTask.date_start;
		lTask.dueDate = gtdTask.date_due;
		NSMutableSet *tagSet = [NSMutableSet set];
		for (NSString *tagString in gtdTask.tags) {
			if ([tagString length] > 0) {
				if ([possibleTags objectForKey:tagString] != nil) {
					// tag in db
					[tagSet addObject:[possibleTags objectForKey:tagString]];
				}
				else {
					// Not in db, add it to db, possible list and task
					Tag *newTag = (Tag *)[NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:aManagedObjectContext];
					newTag.text = tagString;
					[possibleTags setObject:newTag forKey:tagString];
					[tagSet addObject:newTag];
				}
			}
		}
		lTask.tags = [NSSet setWithSet:tagSet];

		//ULTRAZACH alle folders durchsuchen
		
		
		NSMutableSet *mutableRemoteTasks = [lTask mutableSetValueForKey:@"remoteTasks"];
		[mutableRemoteTasks addObject:rTask];
	}
	
	//zuerst innerhalb einer passenden datenstruktur jedem element aus rTask das entsprechende element aus gtdTask zuordnen
	//falls es zu einem rTask element keinen gtdTask gibt:
	//wenn rTask.localTask.deletedByApp != true -> [syncService addTask]
	//falls unzugeordnete gtdfolder übrigbleiben -> neue folder lokal anlegen und gleich daten übernehmen
	return aManagedObjectContext;
}

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

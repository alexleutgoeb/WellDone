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

- (NSManagedObjectContext *)syncData:(NSManagedObjectContext *)aManagedObjectContext {
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
- (void) syncFolders:(NSManagedObjectContext *) aManagedObjectContext withSyncService: (id<GtdApi>) syncService {
	
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
	
	//lokale Objekte nach remoteObjekten durchsuchen und gegebenenfalls adden
	for (Folder *localFolder in localFolders) {
		
		NSEnumerator *enumerator = [localFolder.remoteFolders objectEnumerator];
		
		remoteFolder = nil;
			
		while ((remoteFolder = [enumerator nextObject])) {
			//wenn remoteobject existiert
			if(remoteFolder.serviceIdentifier == syncService.identifier) break;
			else remoteFolder = nil;
		}
		//now we can safely assume, that each local folder has a remoteFolder
		//no remoteFolder was found, create one
		if(remoteFolder == nil) {
			remoteFolder = [NSEntityDescription insertNewObjectForEntityForName:@"RemoteFolder" inManagedObjectContext:aManagedObjectContext];
			remoteFolder.serviceIdentifier = syncService.identifier;
			remoteFolder.remoteUid = nil;
			remoteFolder.lastsyncDate = nil;
			remoteFolder.localFolder = localFolder;
			NSMutableSet *mutableRemoteFolders = [localFolder mutableSetValueForKey:@"remoteFolders"];
			[mutableRemoteFolders addObject:remoteFolder];
		}
		
		//find gtdfolder
		foundGtdFolder = nil;
		for(GtdFolder *gtdFolder in gtdFolders) {
			if(gtdFolder.uid == [remoteFolder.remoteUid integerValue]) {
				[foundGtdFolders addObject:gtdFolder];
				foundGtdFolder = gtdFolder;
				break;
			}
		}
		
		if(
		   (foundGtdFolder == nil && [localFolder.deleted integerValue] != 1) ||
		   remoteFolder.lastsyncDate == nil ||
		   remoteFolder.localFolder.modifiedDate > remoteFolder.lastsyncDate
		   ) {
			GtdFolder *newGtdFolder = [[GtdFolder alloc] init];
			newGtdFolder.uid = [remoteFolder.remoteUid integerValue];
			newGtdFolder.title = localFolder.name;
			if([localFolder.private intValue] == 1)
				newGtdFolder.private = YES;
			else newGtdFolder.private = NO;
			//newGtdFolder.archived = localFolder.archived;
			newGtdFolder.order = [localFolder.order integerValue];
			
			//add new folder if firstsync
			if(remoteFolder.remoteUid == nil) remoteFolder.remoteUid = [NSNumber numberWithInt:[syncService addFolder:newGtdFolder error:&error]];
			//overwrite the remote remoteFolder with the local folder
			else [syncService editFolder:newGtdFolder error:&error];
		}
		else if(foundGtdFolder != nil) {
			localFolder.name = foundGtdFolder.title;
			if(foundGtdFolder.private == YES) localFolder.private = [NSNumber numberWithInt:1];
			else localFolder.private = [NSNumber numberWithInt:0];
			localFolder.order = [NSNumber numberWithInt:foundGtdFolder.order];
		}
	}
	
	//NSMutableArray thxObjC = new NSMutableArray(gtdFolders);
	//finally durchlaufe die gtdFolder die nicht zuordenbar waren und erzeuge sie lokal
	[gtdFolders removeObjectsInArray:foundGtdFolders];
	for(GtdFolder *gtdFolder in gtdFolders) {
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
	}
		
	//zuerst innerhalb einer passenden datenstruktur jedem element aus rFolder das entsprechende element aus gtdFolder zuordnen
		//falls es zu einem rFolder element keinen gtdFolder gibt:
			//wenn rFolder.localFolder.deleted != true -> [syncService addFolder]
		//falls unzugeordnete gtdfolder übrigbleiben -> neue folder lokal anlegen und gleich daten übernehmen
}
/*
 
 syncpseudocode:
 
1. via syncService die gtdFolders holen.

2. aus dem managedObjectContext die remoteFolders holen.

3. jetzt iteriere ich die remoteFolders durch und schau bei jedem ob es einen entsprechenden gtdFolder gibt.

3a Wenn ich einen passenden gtdFolder finde dann als nächstes remoteFolder.localFolder.deleted prüfen:
wenn deleted = true: lösche gtdFolder
sonst als nächstes das remoteFolder.localFolder lastmodified prüfen:
wenn lastmodified > lastsync: gtdFolder mit daten aus remoteFolder.localFolder überschreiben
wenn lastmodified <= lastsync: localFolder mit gtdFolder überschreiben

3b wenn ich keinen passenden gtdFolder finde und remoteFolder.localFolder.deleted != true: neuen gtdFolder anlegen
sonst wenn lastmodified <= lastsync dann bedeuted das, dass der folder in toodledo gelöscht wurde daher: remoteFolder deleten.

4 jetzt die übriggebliebenen gtdFolders hernehmen und für jeden einen remoteFolder + remoteFolder.localFolder anlegen

bei den anderen wird es fast ident sein. nur bei tasks und notes kommt der fall dazu, dass zb gtdTask.lastEdit auch > lastSync ist und dann der user gepromptet werden muss.
*/

@end

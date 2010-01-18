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
	
	if ([syncServices count] > 0) {
		
		// Take only the first sync service from the list
		id<GtdApi> syncService = [syncServices objectForKey:[[syncServices allKeys] objectAtIndex:0]];
		
		// last edited dates
		//NSDictionary *lastDates = [syncService getLastModificationsDates:&error];
		
		
		aManagedObjectContext = [self syncFolders:aManagedObjectContext withSyncService:syncService];
		aManagedObjectContext = [self syncContexts:aManagedObjectContext withSyncService:syncService];
		aManagedObjectContext = [self syncTasks:aManagedObjectContext withSyncService:syncService andConflicts:*&conflicts];
		
		return aManagedObjectContext;
	}
	else {
		// no sync service registered, return nil
		return nil;
	}
}


- (NSManagedObjectContext *) syncFolders:(NSManagedObjectContext *) aManagedObjectContext withSyncService: (id<GtdApi>) syncService {
	
	NSError *error = nil;
	
	//zuerst alle remoteFolders erstellen falls sie noch nicht existieren
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:aManagedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSArray *localFolders = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
	
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
			[aManagedObjectContext deleteObject:localFolder];
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
		
	return aManagedObjectContext;
}


- (NSManagedObjectContext *) syncContexts:(NSManagedObjectContext *) aManagedObjectContext withSyncService: (id<GtdApi>) syncService {
	
	NSError *error = nil;
	
	//zuerst alle remoteContexts erstellen falls sie noch nicht existieren
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Context" inManagedObjectContext:aManagedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSArray *localContexts = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
	//now find a corresponding GTDcontext
	NSMutableArray *gtdContexts = (NSMutableArray *) [syncService getContexts:&error];
	NSMutableArray *foundGtdContexts = [[NSMutableArray alloc] init];
	GtdContext *foundGtdContext;
	RemoteContext *remoteContext;
	DLog(@"xxxxxxxxxxxxx    schleifenbeginn  contexts  xxxxxxxxxxxx ");
	//lokale Objekte nach remoteObjekten durchsuchen und gegebenenfalls adden
	for (Context *localContext in localContexts) {
		DLog(@"localContext.title %@", localContext.title);
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
		
		if([localContext.deletedByApp integerValue] == 1) {
			DLog(@"syncContext deleting context: %@", localContext.title);
			if(foundGtdContext != nil)
				[syncService deleteContext:foundGtdContext error:&error];
			[aManagedObjectContext deleteObject:localContext];
		} else if(foundGtdContext == nil) {
			DLog(@"syncContext deleting cos no foundGtdContext: %@", localContext.title);
			[aManagedObjectContext deleteObject:localContext];
			
		//} else if ([localContext.modifiedDate timeIntervalSinceDate:remoteContext.lastsyncDate] == 0) {

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
			newGtdContext.title = localContext.title;
			//overwrite the remote remoteContext with the local context
			[syncService editContext:newGtdContext error:&error];
			remoteContext.lastsyncDate = [NSDate date];
		}
		DLog(@"error %@", [error description]);
	}

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
	return aManagedObjectContext;
}


- (NSManagedObjectContext *)syncTasks:(NSManagedObjectContext *)aManagedObjectContext withSyncService:(id<GtdApi>)syncService andConflicts:(NSArray **)conflicts {
	
	NSError *error = nil;
	NSMutableDictionary *possibleTags = [NSMutableDictionary dictionary];
	
	// Load all possible tags in a dictionary named possibleTags
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:aManagedObjectContext];
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

	NSMutableArray *actualConflicts = [[[NSMutableArray alloc] init] autorelease];

	RemoteTask *remoteTask;
	DLog(@"xxxxxxxxxxxxx    schleifenbeginn    xxxxxxxxxxxx ");
	//lokale Objekte nach remoteObjekten durchsuchen und gegebenenfalls adden
	for (Task *localTask in localTasks) {
		DLog(@"Looking for a remote task for '%@'...", localTask.title);

		if ([[localTask.remoteTasks subsetWithKey:@"serviceIdentifier" value:syncService.identifier] count] == 1) {
			// Remote task found
			remoteTask = [[localTask.remoteTasks subsetWithKey:@"serviceIdentifier" value:syncService.identifier] anyObject];
			DLog(@"Found remote task with remote uid: %i.", remoteTask.remoteUid);
			
			// Look for a corresponding gtdtask
			NSSet *gtdTaskSet = [NSSet setWithArray:gtdTasks];
			if ([[gtdTaskSet subsetWithKey:@"uid" value:remoteTask.remoteUid] count] == 1) {
				// Found corresponding gtdtask, update both
				GtdTask *gtdTask = [[gtdTaskSet subsetWithKey:@"uid" value:remoteTask.remoteUid] anyObject];
				DLog(@"Found GtdTask...");
				
				// Check if task was deleted locally
				DLog(@"Check if task was deleted locally...");
				if ([localTask.deletedByApp boolValue] == YES) {
					// Task deleted locally, delete remote, afterwards local
					error = nil;
					[syncService deleteTask:gtdTask error:&error];
					if (error == nil) {
						// Task deleted remotely
						[aManagedObjectContext deleteObject:localTask];
					}
					DLog(@"Task was deleted locally, so deleted remotely too.");
				}
				else {
					// Task not deleted, update
					DLog(@"Task was not deleted locally, update...");
					
					// Check last modified dates
					DLog(@"Local task: %@", localTask.modifiedDate);
					DLog(@"Gtd task:   %@", gtdTask.date_modified);
					DLog(@"Last sync:  %@", remoteTask.lastsyncDate);
					
					if([localTask.modifiedDate timeIntervalSinceDate:remoteTask.lastsyncDate] > 0.9 && [gtdTask.date_modified timeIntervalSinceDate:remoteTask.lastsyncDate] <= 0.1) {
						// Update of remote task by local task
						DLog(@"Update remote task by local task (newer)...");
						gtdTask.title = localTask.title;
						gtdTask.priority = [localTask.priority integerValue];
						gtdTask.length = [localTask.length integerValue];
						gtdTask.note = localTask.note;
						gtdTask.star = [localTask.starred boolValue];
						gtdTask.repeat = [localTask.repeat integerValue];
						gtdTask.status = [localTask.status integerValue];
						gtdTask.reminder = [localTask.reminder integerValue];
						gtdTask.parentId = [remoteTask.remoteUid intValue];
						gtdTask.date_due = localTask.dueDate;
						gtdTask.date_start = localTask.startDate;
						
						if ([localTask.tags count] > 0)
							gtdTask.tags = [[localTask.tags valueForKey:@"text"] allObjects];
						if([localTask.completed boolValue] == YES)
							gtdTask.completed = [NSDate date];

						RemoteFolder *remoteFolder = [[localTask.folder.remoteFolders subsetWithKey:@"serviceIdentifier" value:syncService.identifier] anyObject];
						if (remoteFolder)
							gtdTask.folder = [remoteFolder.remoteUid intValue];
						else
							gtdTask.folder = 0;

						
						RemoteContext *remoteContext = [[localTask.context.remoteContexts subsetWithKey:@"serviceIdentifier" value:syncService.identifier] anyObject];
						if (remoteContext)
							gtdTask.context = [remoteContext.remoteUid intValue];
						else
							gtdTask.context = 0;
						
						// Overwrite the remote task with the local one
						error = nil;
						[syncService editTask:gtdTask error:&error];
						if (error == nil) {
							remoteTask.lastsyncDate = [NSDate date];
							DLog(@"Task '%@' updated successfully.", localTask.title);
						}
					}
					
					else if ([localTask.modifiedDate timeIntervalSinceDate:remoteTask.lastsyncDate] <= 0.1 && [gtdTask.date_modified timeIntervalSinceDate:remoteTask.lastsyncDate] > 0.9) {
						// Update of local task by remote one
						DLog(@"Update local task by remote task (newer)...");
						// Set local task properties
						localTask.title = gtdTask.title;
						localTask.status = [NSNumber numberWithInt:gtdTask.status];
						localTask.startDate = gtdTask.date_start;
						localTask.starred = [NSNumber numberWithBool:gtdTask.star];
						localTask.repeat = [NSNumber numberWithInt:gtdTask.repeat];
						localTask.reminder = [NSNumber numberWithInt:gtdTask.reminder];
						localTask.priority = [NSNumber numberWithInt:gtdTask.priority];
						localTask.note = gtdTask.note;
						localTask.length = [NSNumber numberWithInt:gtdTask.length];
						localTask.dueDate = gtdTask.date_due;
						localTask.completed = (gtdTask.completed == nil) ? [NSNumber numberWithInt:0] : [NSNumber numberWithInt:1];
						
						// Tags
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
						localTask.tags = [NSSet setWithSet:tagSet];
						
						// Context
						if (gtdTask.context > 0) {
							fetchRequest = [[NSFetchRequest alloc] init];
							entity = [NSEntityDescription entityForName:@"RemoteContext" inManagedObjectContext:aManagedObjectContext];
							[fetchRequest setEntity:entity];
							NSPredicate *predicate = [NSPredicate predicateWithFormat:@"remoteUid == %i AND serviceIdentifier like %@", gtdTask.context, syncService.identifier];
							[fetchRequest setPredicate:predicate];
							error = nil;
							NSArray *allContext = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
							if (allContext != nil && [allContext count] == 1) {
								// Found context
								RemoteContext *remoteContext = [allContext objectAtIndex:0];
								localTask.context = remoteContext.localContext;
							}
							else {
								// Error, context should be in database, annoying...
							}
							[fetchRequest release];
						}
						
						// Folder
						if (gtdTask.folder > 0) {
							fetchRequest = [[NSFetchRequest alloc] init];
							entity = [NSEntityDescription entityForName:@"RemoteFolder" inManagedObjectContext:aManagedObjectContext];
							[fetchRequest setEntity:entity];
							NSPredicate *predicate = [NSPredicate predicateWithFormat:@"remoteUid == %i AND serviceIdentifier like %@", gtdTask.folder, syncService.identifier];
							[fetchRequest setPredicate:predicate];
							error = nil;
							NSArray *allFolder = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
							if (allFolder != nil && [allFolder count] == 1) {
								// Found folder
								RemoteFolder *remoteFolder = [allFolder objectAtIndex:0];
								localTask.folder = remoteFolder.localFolder;
							}
							else {
								// Error, folder should be in database, annoying...
							}
							[fetchRequest release];
						}
						
						// Parent task
						if (gtdTask.parentId == 0) {
							// Inbox
							localTask.parentTask = nil;
						}
						else if (gtdTask.parentId > 0) {
							// Has parent task, look up
							fetchRequest = [[NSFetchRequest alloc] init];
							entity = [NSEntityDescription entityForName:@"RemoteTask" inManagedObjectContext:aManagedObjectContext];
							[fetchRequest setEntity:entity];
							NSPredicate *predicate = [NSPredicate predicateWithFormat:@"remoteUid == %i AND serviceIdentifier like %@", gtdTask.parentId, syncService.identifier];
							[fetchRequest setPredicate:predicate];
							error = nil;
							NSArray *allTasks = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
							if (allTasks != nil && [allTasks count] == 1) {
								// Found parent task
								RemoteTask *remoteParentTask = [allTasks objectAtIndex:0];
								localTask.parentTask = remoteParentTask.localTask;
							}
							else {
								// Error, task should be in database, annoying...
							}
							[fetchRequest release];
						}
						
						remoteTask.lastsyncDate = [NSDate date];
						DLog(@"Task '%@' updated successfully.", localTask.title);
					}
					
					else if([localTask.modifiedDate timeIntervalSinceDate:remoteTask.lastsyncDate] > 0.9 && [gtdTask.date_modified timeIntervalSinceDate:remoteTask.lastsyncDate] > 0.9) {
						// Conflict
						DLog(@"task conflicted, create a conflict container");
						TaskContainer *tc = [[[TaskContainer alloc] init] autorelease];
						tc.gtdTask = gtdTask;
						tc.remoteTask = remoteTask;
						[actualConflicts addObject:tc];
					}
					else {
						// Nothing to do
						DLog(@"Task has not changed since last sync, nothing to do.");
					}
				}
				// Remove gtdTask from array finally
				[gtdTasks removeObject:gtdTask];
			}
			else {
				// Task not found, deleted remotely
				DLog(@"No corresponding gtd task found, remove locally.");
				[aManagedObjectContext deleteObject:localTask];
				// If getDeletedTasks not called, delete the task
			}
		}
		else {
			// No remote task found, create one
			DLog(@"No remote task found, create one...");
			remoteTask = [NSEntityDescription insertNewObjectForEntityForName:@"RemoteTask" inManagedObjectContext:aManagedObjectContext];
			remoteTask.serviceIdentifier = syncService.identifier;
			remoteTask.localTask = localTask;
			
			DLog(@"Sync new remote task to api...");
			GtdTask *newGtdTask = [[GtdTask alloc] init];

			newGtdTask.title = localTask.title;
			newGtdTask.uid = 0;
			newGtdTask.priority = [localTask.priority integerValue];
			newGtdTask.length = [localTask.length integerValue];
			newGtdTask.note = localTask.note;
			newGtdTask.star = [localTask.starred boolValue];
			newGtdTask.repeat = [localTask.repeat integerValue];
			newGtdTask.status = [localTask.status integerValue];
			newGtdTask.reminder = [localTask.reminder integerValue];
			newGtdTask.parentId = [remoteTask.remoteUid intValue];
			newGtdTask.date_due = localTask.dueDate;
			newGtdTask.date_start = localTask.startDate;

			if ([localTask.tags count] > 0)
				newGtdTask.tags = [[localTask.tags valueForKey:@"text"] allObjects];
			if([localTask.completed boolValue] == YES)
				newGtdTask.completed = [NSDate date];
			
			RemoteFolder *remoteFolder = [[localTask.folder.remoteFolders subsetWithKey:@"serviceIdentifier" value:syncService.identifier] anyObject];
			if (remoteFolder)
				newGtdTask.folder = [remoteFolder.remoteUid intValue];
			
			RemoteContext *remoteContext = [[localTask.context.remoteContexts subsetWithKey:@"serviceIdentifier" value:syncService.identifier] anyObject];
			if (remoteContext)
				newGtdTask.context = [remoteContext.remoteUid intValue];

			error = nil;
			remoteTask.remoteUid = [NSNumber numberWithInt:[syncService addTask:newGtdTask error:&error]];
			if (error != nil) {
				// Error while syncing, rollback?
				DLog(@"Error: Can't add task '%@' to api: %@", localTask.title, [error localizedDescription]);
				// Remove remote task again
				[aManagedObjectContext deleteObject:remoteTask];
			}
			else {
				// Task added
				DLog(@"Task added to api with remote id: %@.", remoteTask.remoteUid);
				remoteTask.lastsyncDate = [NSDate date];
			}
			[newGtdTask release];
		}
	}
	
	
	
	// Iterate undone gtdTasks and add locally
	for (GtdTask *gtdTask in gtdTasks) {
		DLog(@"Adding new local task '%@'...", gtdTask.title);
		
		// Add new entities
		RemoteTask *remoteTask = [NSEntityDescription insertNewObjectForEntityForName:@"RemoteTask" inManagedObjectContext:aManagedObjectContext];
		Task *localTask = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:aManagedObjectContext];
		
		// Set remote task properties
		remoteTask.localTask = localTask;
		remoteTask.serviceIdentifier = syncService.identifier;
		remoteTask.lastsyncDate = [NSDate date];
		remoteTask.remoteUid = [NSNumber numberWithInt:gtdTask.uid];
		
		// Set local task properties
		localTask.title = gtdTask.title;
		localTask.status = [NSNumber numberWithInt:gtdTask.status];
		localTask.startDate = gtdTask.date_start;
		localTask.starred = [NSNumber numberWithBool:gtdTask.star];
		localTask.repeat = [NSNumber numberWithInt:gtdTask.repeat];
		localTask.reminder = [NSNumber numberWithInt:gtdTask.reminder];
		localTask.priority = [NSNumber numberWithInt:gtdTask.priority];
		localTask.note = gtdTask.note;
		localTask.length = [NSNumber numberWithInt:gtdTask.length];
		localTask.dueDate = gtdTask.date_due;
		localTask.completed = (gtdTask.completed == nil) ? [NSNumber numberWithInt:0] : [NSNumber numberWithInt:1];
		
		// Tags
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
		localTask.tags = [NSSet setWithSet:tagSet];
		
		// Context
		if (gtdTask.context > 0) {
			fetchRequest = [[NSFetchRequest alloc] init];
			entity = [NSEntityDescription entityForName:@"RemoteContext" inManagedObjectContext:aManagedObjectContext];
			[fetchRequest setEntity:entity];
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"remoteUid == %i AND serviceIdentifier like %@", gtdTask.context, syncService.identifier];
			[fetchRequest setPredicate:predicate];
			error = nil;
			NSArray *allContext = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
			if (allContext != nil && [allContext count] == 1) {
				// Found context
				RemoteContext *remoteContext = [allContext objectAtIndex:0];
				localTask.context = remoteContext.localContext;
			}
			else {
				// Error, context should be in database, annoying...
			}
			[fetchRequest release];
		}
		
		// Folder
		if (gtdTask.folder > 0) {
			fetchRequest = [[NSFetchRequest alloc] init];
			entity = [NSEntityDescription entityForName:@"RemoteFolder" inManagedObjectContext:aManagedObjectContext];
			[fetchRequest setEntity:entity];
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"remoteUid == %i AND serviceIdentifier like %@", gtdTask.folder, syncService.identifier];
			[fetchRequest setPredicate:predicate];
			error = nil;
			NSArray *allFolder = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
			if (allFolder != nil && [allFolder count] == 1) {
				// Found folder
				RemoteFolder *remoteFolder = [allFolder objectAtIndex:0];
				localTask.folder = remoteFolder.localFolder;
			}
			else {
				// Error, folder should be in database, annoying...
			}
			[fetchRequest release];
		}
		
		// Parent task
		if (gtdTask.parentId == 0) {
			// Inbox
			localTask.parentTask = nil;
		}
		else if (gtdTask.parentId > 0) {
			// Has parent task, look up
			fetchRequest = [[NSFetchRequest alloc] init];
			entity = [NSEntityDescription entityForName:@"RemoteTask" inManagedObjectContext:aManagedObjectContext];
			[fetchRequest setEntity:entity];
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"remoteUid == %i AND serviceIdentifier like %@", gtdTask.parentId, syncService.identifier];
			[fetchRequest setPredicate:predicate];
			error = nil;
			NSArray *allTasks = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
			if (allTasks != nil && [allTasks count] == 1) {
				// Found parent task
				RemoteTask *remoteParentTask = [allTasks objectAtIndex:0];
				localTask.parentTask = remoteParentTask.localTask;
			}
			else {
				// Error, task should be in database, annoying...
			}
			[fetchRequest release];
		}
		
	}

	if ([actualConflicts count] > 0) {
		// Conflicts
		*conflicts = actualConflicts;
	}
	return aManagedObjectContext;
}

@end
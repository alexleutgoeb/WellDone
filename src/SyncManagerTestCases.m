//
//  SyncManagerTestCases.m
//  WellDone
//
//  Created by Michael Petritsch on 27.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SyncManagerTestCases.h"

#import "TDApi.h"
#import "Folder.h"


@implementation SyncManagerTestCases

- (void)setUp {
	//DLog(@"hola");

	NSString *user = @"michael.petritsch@gmail.com";
	NSString *pwd = @"123temppw";
	NSError *error = nil;
	
	sc = [[SyncController alloc] init];
	[sc enableSyncService:@"syncservice.toodledo-objc" withUser:user pwd:pwd error:&error];
	api = [[TDApi alloc] initWithUsername:user password:pwd error:&error];
	sm = [[SyncManager alloc] init];
	[sm registerSyncService:api];
	//und dann dem syncmanager mit registerService übergeben
	
	//dann kannst syncFolder:moc
	persistentStoreCoordinator = [self persistentStoreCoordinator];
	managedObjectContext = [self managedObjectContext];
	
}

- (void)tearDown {
	
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
    if (persistentStoreCoordinator) return persistentStoreCoordinator;
	
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
	NSURL *coreDataDBLocationURL = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"WellDoneTest.welldonedoc"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
												  configuration:nil 
															URL:coreDataDBLocationURL 
														options:nil 
														  error:&error]){//change between XML and DB saved local (NSSQLiteStoreType vs. NSXMLStoreType)
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    
	
	NSURL *url = [NSURL URLWithString:@"memory://store"];
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
												  configuration:nil
															URL:url
														options:nil
														  error:&error]) {
		[[NSApplication sharedApplication] presentError:error];
	}
	
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext) return managedObjectContext;
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];
	
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

- (NSString *)applicationSupportDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"WellDone"];
}

//Folder tests

-(void)FolderSyncWithLocalModifiedDateGreaterLastSync {

}


-(void)FolderSyncWithLocalModifiedDateLessOrEqualLastSync {
	
}


-(void)FolderCreatedLocal {
	
	Folder *lFolder = [NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:managedObjectContext];
	lFolder.name = @"testFolder";
	[sm syncFolders:managedObjectContext withSyncService:api];
	
	NSError *error;
	NSArray *gtdFolders = (NSArray *) [api getFolders:&error];
	GtdFolder *gtdFolder = [gtdFolders lastObject];
	
	STAssertTrue([lFolder.name isEqualToString:gtdFolder.title], @"lFolder.name != gtdFolder.title. Expected %i, got %i", lFolder.name, gtdFolder.title);
	
	//Folder localFolder = [[new Folder alloc] init];
	//RemoteFolder remoteFolder = [[new RemoteFolder alloc] init];
	
	//localFolder.title = "test";
	//localFolder.modifiedDate = [NSDate date];
}


-(void)FolderCreatedRemote {
	
}


-(void)FolderDeleteLocal {
	
}


-(void)FolderDeleteRemote {
	
}


//Context tests


-(void)ContextSyncWithLocalModifiedDateGreaterLastSync {
	
}


-(void)ContextSyncWithLocalModifiedDateLessOrEqualLastSync {
	
}


-(void)ContextCreatedLocal {
	
}


-(void)ContextCreatedRemote {
	
}


-(void)ContextDeleteLocal {
	
}


-(void)ContextDeleteRemote {
	
}


//Note tests


-(void)NoteSyncWithLocalModifiedDateGreaterLastSyncGreaterOrEqualRemoteDate_Modified {
	
}


-(void)NoteSyncWithLocalAndRemoteDatesLessOrEqualLastSync {
	
}


-(void)NoteSyncWithLocalModifiedDateLessOrEqualLastSyncLessRemoteDateModified {
	
}


-(void)NoteSyncWithLocalAndRemoteGreaterLastSync {
	
}


-(void)NoteCreatedLocal {
	
}


-(void)NoteCreatedRemote {
	
}


-(void)NoteDeleteLocal {
	
}


-(void)NoteDeleteRemote {
	
}


//Task tests


-(void)TaskSyncWithLocalModifiedDateGreaterLastSyncGreaterOrEqualRemoteDate_Modified {
	
}


-(void)TaskSyncWithLocalAndRemoteDatesLessOrEqualLastSync {
	
}


-(void)TaskSyncWithLocalModifiedDateLessOrEqualLastSyncLessRemoteDateModified {
	
}


-(void)TaskSyncWithLocalAndRemoteGreaterLastSync {
	
}


-(void)TaskCreatedLocal {
	
}


-(void)TaskCreatedRemote {
	
}


-(void)TaskDeleteLocal {
	
}


-(void)TaskDeleteRemote {
	
}

@end

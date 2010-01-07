//
//  CoreDataBackup.m
//  WellDone
//
//  Created by Christian Hattinger on 07.01.10.
//  Copyright 2010 TU Wien. All rights reserved.
//

#import "CoreDataBackup.h"


@implementation CoreDataBackup


// make a copy of the core data file
- (BOOL)backupDatabaseFile:(NSString *)backupPath error:(NSError **)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    

	
    // insist that the file which should be backuped does exist
	NSAssert1([fm fileExistsAtPath:	[[NSApp delegate] coreDataDBLocaionURL]], @"no db file at %@", [[NSApp delegate] coreDataDBLocaionURL]);

	
	//    NSAssert1([fm fileExistsAtPath:backupPath], @"no backup db file at %@", backupPath);
	
    // remove the original to make way for the backup
//    NSLog(@"removing the file at the primary database path...");

    
	
//	[self presentError:error]; // at this point we're in real trouble
    return NO;
}



// replace current core data file with a existing one (as from a backup). --> migrate (http://developer.apple.com/iphone/library/documentation/Cocoa/Reference/CoreDataFramework/Classes/NSPersistentStoreCoordinator_Class/NSPersistentStoreCoordinator.html#//apple_ref/occ/instm/NSPersistentStoreCoordinator/migratePersistentStore:toURL:options:withType:error:) or newstart


@end

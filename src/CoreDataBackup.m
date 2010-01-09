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
- (BOOL)backupDatabaseFile:(NSString *)backupPath {
    NSFileManager *fm = [NSFileManager defaultManager];
    
	NSURL *currentDBFile = [[NSApp delegate] coreDataDBLocationURL];
	
//	NSLog([currentDBFile absoluteString]);
	
	/*
	NSLog(currentDBFile);
	
    // insist that the file which should be backuped does exist--> eher ein if
//	NSAssert1([fm fileExistsAtPath:	[currentDBFile absoluteString], @"no db file at %@", currentDBFile]);

	// create the new file (if the folder does not exist, the method creates it)
	// todo: eventuell nicht noetig wegen copyItemAtURL
	if (![fm createDirectoryAtPath:backupPath withIntermediateDirectories:YES attributes:nil error:nil]){
		//errorhandling
	}
		 */  
			   
	
	// create a file name out of the backupPath
	NSDate *date = [NSDate date];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"YYYY-MM-DD_HH_MM_SS"];
//	NSString *dateString = [dateFormat stringFromDate:date]; 
//	NSMutableString *backupFileName = [NSString stringWithString: currentDBFile];
	//[backupFileName appendString:dateString];
	//NSLog(@"The backup file will be named %@", backupFileName);
	
	//[fm copyItemAtURL:currentDBFile toURL:backupFileName error:nil];
	
    return YES;
}



// replace current core data file with a existing one (as from a backup). --> migrate (http://developer.apple.com/iphone/library/documentation/Cocoa/Reference/CoreDataFramework/Classes/NSPersistentStoreCoordinator_Class/NSPersistentStoreCoordinator.html#//apple_ref/occ/instm/NSPersistentStoreCoordinator/migratePersistentStore:toURL:options:withType:error:) or newstart


@end

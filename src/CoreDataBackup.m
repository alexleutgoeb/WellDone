//
//  CoreDataBackup.m
//  WellDone
//
//  Created by Christian Hattinger on 07.01.10.
//  Copyright 2010 TU Wien. All rights reserved.
//

#import "CoreDataBackup.h"


@implementation CoreDataBackup


// workaround for error domain initialization
NSString *const CoreDataBackupError = @"CoreDataBackupErrorDomain";

- (IBAction)createBackupAction:(id)sender {

	
	NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
//	NSString *location = [[NSApp delegate] applicationSupportDirectory ]; 
	NSString *location = (NSString *)[defaults objectForKey:@"backupPath"];//TODO: fehlerbehandlung
	
	NSError *error;	
	NSAlert *alert = [[NSAlert alloc] init];
	NSString *filelocation = [self backupDatabaseFile:location error:&error];
	if (filelocation != nil){
		NSString *message = NSLocalizedString([@"Backup was successful. \n You can find the Backupfile here: " stringByAppendingPathComponent: filelocation], @"backup was successful, location of the file is here:" );
		
		[alert setMessageText:message];	
		[alert runModal];
	}else {
		[[NSAlert alertWithError:error] runModal];	
	}

	
}

// make a copy of the core data file
- (id)backupDatabaseFile:(NSString *)backupPath error:(NSError **)error {

	// moc speichern
	NSManagedObjectContext *moc;
	moc = [[NSApp delegate] managedObjectContext];
	NSError *err = nil;
	if (![moc save:&err]) {
		DLog(@"Error saving moc for backup, don't know what to do.");
	} else {
		DLog(@"Saved moc for backup.");
	}
	
	//TODO: check the path ending
	backupPath = [backupPath stringByAppendingString:@"/"];
	//NSLog(backupPath);
    NSFileManager *fm = [NSFileManager defaultManager];
    
	NSURL *currentDBFile = [[NSApp delegate] coreDataDBLocationURL];

	// checks if the backup directory exisits and creates it if not
	if (![fm fileExistsAtPath:backupPath]){ 
		// create the new file (if the folder does not exist, the method creates it). Errors are handled in the NSError error and nil is returned in case of problems
		if (![fm createDirectoryAtPath:backupPath withIntermediateDirectories:YES attributes:nil error:&*error]){
			return nil;
		}	
	}
	
	// create a file name out of the backupPath
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"YYYY-MM-DD_HH_MM_SS"];
	NSString *fileEnding;
	fileEnding = [ [dateFormat stringFromDate:[NSDate date]] stringByAppendingString:@"_WellDone.welldonedoc"];

	NSString *backupFileName = [backupPath stringByAppendingString:fileEnding];
	
	NSURL *backupFileURL = [NSURL fileURLWithPath: backupFileName];

	if ([fm copyItemAtURL:currentDBFile toURL:backupFileURL error:&*error]){
		return [backupFileURL absoluteString];
	}else {
		return nil;
	}

}


- (BOOL)replaceDatabaseFileWithBackupFile:(NSString *)backupFilePath{


	return NO;
}


@end

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

	NSString *location = [[NSApp delegate] applicationSupportDirectory ]; //TODO

	
	
	NSError *error;	
	NSAlert *alert = [[NSAlert alloc] init];
	if ([self backupDatabaseFile:location error:&error]){
		NSString *message = NSLocalizedString([@"Backup was successful. \nLocation of the backupfile: " stringByAppendingPathComponent: location], @"backup was successful, saved file into the directory:" );
		
		[alert setMessageText:message];	
		[alert runModal];
	}else {
		[[NSAlert alertWithError:error] runModal];	
	}

	
}

// make a copy of the core data file
- (BOOL)backupDatabaseFile:(NSString *)backupPath error:(NSError **)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    
	NSURL *currentDBFile = [[NSApp delegate] coreDataDBLocationURL];
	BOOL temp = [fm fileExistsAtPath:[currentDBFile absoluteString]];
	
	/*
    // insist that the file which should be backuped does exist
	if (![fm fileExistsAtPath:[currentDBFile absoluteString]] && error !=nil){ // 
		NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:@"Directory or Filename of the Database does not exist" forKey:NSLocalizedDescriptionKey]; //TODO: also give user the location
		[errorDetail setValue:@"Please chose an existing directory" forKey:NSLocalizedRecoverySuggestionErrorKey];		
		error = [NSError errorWithDomain:CoreDataBackupError code:1 userInfo:errorDetail];
		return NO;
	}
	*/
	// checks if the backup directory exisits and creates it if not
	if (![fm fileExistsAtPath:backupPath]){ //TODO: isdirectory and can write
		// create the new file (if the folder does not exist, the method creates it)
		if (![fm createDirectoryAtPath:backupPath withIntermediateDirectories:YES attributes:nil error:&error]){
			return NO;
		}	
	}
	
	// create a file name out of the backupPath
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"YYYY-MM-DD_HH_MM_SS"];
	NSString *fileEnding;
	fileEnding = [ [dateFormat stringFromDate:[NSDate date]] stringByAppendingString:@"_WellDone.welldonedoc"];

	NSString *backupFileName;
	backupFileName = [backupPath stringByAppendingString:fileEnding];
	
	NSURL *backupFileURL = [NSURL fileURLWithPath: backupFileName];

	return	[fm copyItemAtURL:currentDBFile toURL:backupFileURL error:&error];

}


- (BOOL)replaceDatabaseFileWithBackupFile:(NSString *)backupFilePath{


	return NO;
}


@end

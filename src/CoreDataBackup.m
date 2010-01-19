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

	// save moc
	NSManagedObjectContext *moc;
	moc = [[NSApp delegate] managedObjectContext];
	NSError *err = nil;
	if (![moc save:&err]) {
		DLog(@"Error saving moc for backup, don't know what to do.");
	} else {
		DLog(@"Saved moc for backup.");
	}
	
	// create backupfile name and directory (if it does not exist)
	backupPath = [backupPath stringByAppendingString:@"/"];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"YYYY-MM-DD_HH_MM_SS"];
	NSString *backupFileName = [backupPath stringByAppendingString:[ [dateFormat stringFromDate:[NSDate date]] stringByAppendingString:@"_WellDone.welldonedoc"]];
	
	NSString *currentDBFile = [[[NSApp delegate] coreDataDBLocationURL] path];

	NSFileManager *fm = [NSFileManager defaultManager];
	if (![fm fileExistsAtPath:backupPath]){ 
		// create the new file (if the folder does not exist, the method creates it). Errors are handled in the NSError error and nil is returned in case of problems
		if (![fm createDirectoryAtPath:backupPath withIntermediateDirectories:YES attributes:nil error:&*error]){
			return nil;
		}	
	}
	
	if ([fm copyItemAtPath:currentDBFile toPath:backupFileName error:error]){
		return backupFileName;
	}
	return nil;
}

- (IBAction)restoreBackupAction:(id)sender {	
	NSOpenPanel *op = [NSOpenPanel openPanel];
	
	if ([op runModal] == NSOKButton)
	{
		NSString *filename = [op filename];
			
		NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
		[defaults setObject:filename forKey:@"restoreBackupAtStart"];
			
		int buttonPressed = NSRunCriticalAlertPanel(
													@"Please restart WellDone!",
													@"WellDone will restore to your selected backup after restart.",
													@"Ok",
													nil,
													nil);
		// restart the app
		[NSApp relaunch:nil];
	}
}


- (IBAction)doAutoBackup:(id)sender {
	[self handleAutoBackupTimer];

}

- (void)handleAutoBackupTimer{
	NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
	NSNumber *automaticBackup = (NSNumber *)[defaults objectForKey:@"automaticBackup"];//TODO: fehlerbehandlung
	NSNumber *timeinterVal = (NSNumber *) [defaults objectForKey:@"automaticBackupValue"];
	NSTimer *timer = [[NSApp delegate] autoBackupTimer] ;	
	
	if ([automaticBackup intValue] == 0) return;

	if (timer != nil){
		[timer invalidate];
	}
	timer = [NSTimer scheduledTimerWithTimeInterval: ([timeinterVal intValue] * 60) target:self selector:@selector(createBackupActionInBackround:) userInfo:nil repeats: YES];
	[[NSApp delegate] setAutoBackupTimer:timer];
}


- (void)createBackupActionInBackround:(NSTimer*)timer {	
	NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
	NSString *location = (NSString *)[defaults objectForKey:@"backupPath"];//TODO: fehlerbehandlung
	NSError *error;	
	NSString *filelocation = [self backupDatabaseFile:location error:&error];
	if (filelocation != nil){
		NSLog([@"AutoBackup was successful. You can find the Backupfile here: " stringByAppendingPathComponent: filelocation]);
		}else {
		NSLog(@"AutoBackup faild: %@", error);
	}
	
	

}

@end

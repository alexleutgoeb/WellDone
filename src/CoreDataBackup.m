//
//  CoreDataBackup.m
//  WellDone
//
//  Created by Christian Hattinger on 07.01.10.
//  Copyright 2010 TU Wien. All rights reserved.
//

#import "CoreDataBackup.h"


@implementation CoreDataBackup

- (IBAction)createBackupAction:(id)sender {
	NSError *error;	
	NSAlert *alert = [[NSAlert alloc] init];
	
	NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
//	NSString *location = [[NSApp delegate] applicationSupportDirectory ]; 
	NSString *location = (NSString *)[defaults objectForKey:@"backupPath"];

	// error handling for the case no key is saved in the defaults
	if (location == nil){
		NSString *message = NSLocalizedString(@"Backup faild. \n Please enter a backuppath in the program settings", @"Backup faild. Please enter a backuppath in the program settings" );
		[alert setMessageText:message];	
		[alert runModal];
		return;
	}

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
	NSFileManager *fm = [NSFileManager defaultManager];
	backupPath = [backupPath stringByAppendingString:@"/"];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"YYYY-MM-DD_HH_MM_SS"];
	NSString *backupFileName = [backupPath stringByAppendingString:[ [dateFormat stringFromDate:[NSDate date]] stringByAppendingString:@"_WellDone.welldonedoc"]];
	
	NSString *currentDBFile = [[[NSApp delegate] coreDataDBLocationURL] path];
	
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
					
		int buttonPressed = NSRunCriticalAlertPanel(
													@"Would you really like to restore the backup",
													@"WellDone will replace the current state (tasks, folders, ...) with the state of the backupfile",
													@"Ok",
													@"Cancel",
													nil);
		if (buttonPressed == 1){ //OK pressed
			NSString *filename = [op filename];
			
			NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
			[defaults setObject:filename forKey:@"restoreBackupAtStart"];
					
		// restart the app
			[NSApp relaunch:nil];
		}
	}
}


- (IBAction)doAutoBackup:(id)sender {
	[self handleAutoBackupTimer];

}

- (void)handleAutoBackupTimer{
	NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
	NSNumber *automaticBackup = (NSNumber *)[defaults objectForKey:@"automaticBackup"];
	NSNumber *timeinterVal = (NSNumber *) [defaults objectForKey:@"automaticBackupValue"];
	NSTimer *timer = [[NSApp delegate] autoBackupTimer] ;	
	
	// error handling for the case no key is saved in the defaults
	if (automaticBackup == nil || timeinterVal == nil ){
		NSLog(@"AutoBackup init faild: either the automaticBackup or the automaticBackupValue in the user defaults is not set");
		return;
	}
	
	if ([automaticBackup intValue] == 0) return;

	if (timer != nil){
		[timer invalidate];
	}
	timer = [NSTimer scheduledTimerWithTimeInterval: ([timeinterVal intValue] * 60) target:self selector:@selector(createBackupActionInBackround:) userInfo:nil repeats: YES];
	[[NSApp delegate] setAutoBackupTimer:timer];
}


- (void)createBackupActionInBackround:(NSTimer*)timer {	
	NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
	NSString *location = (NSString *)[defaults objectForKey:@"backupPath"];
	
	if (location == nil){
		NSLog(@"AutoBackup init in backround faild: the backupPath in the user defaults is not set");
		return;
	}
	
	NSError *error;	
	NSString *filelocation = [self backupDatabaseFile:location error:&error];
	if (filelocation != nil){
		NSLog(@"AutoBackup was successful. You can find the Backupfile here: %@", filelocation);
		}else {
		NSLog(@"AutoBackup faild: %@", error);
	}

}

@end

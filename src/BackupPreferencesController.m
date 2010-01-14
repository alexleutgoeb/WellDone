//
//  BackupPreferencesController.m
//  WellDone
//
//  Created by Christian Hattinger on 12.01.10.
//  Copyright 2010 TU Wien. All rights reserved.
//

#import "BackupPreferencesController.h"


@implementation BackupPreferencesController
@synthesize backupPath;

- (IBAction)doOpen:(id)pId; {
	
	int result;
	
    NSArray *fileTypes = [NSArray arrayWithObject:@"td"];
	
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	

    [oPanel setAllowsMultipleSelection:NO];
	[oPanel setCanChooseFiles:NO];
	[oPanel setCanChooseDirectories:YES];
	
    result = [oPanel runModalForDirectory:NSHomeDirectory()
			  
									 file:nil types:nil];
	
	
    if (result == NSOKButton) {
		
        NSArray *filesToOpen = [oPanel filenames];
		
        NSString *aFile = [filesToOpen objectAtIndex:0];	
		NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
		[defaults setObject:aFile forKey:@"backupPath"];
		[backupPath setStringValue:aFile];
		
		
		
        }
		
    
}
@end

//
//  BackupPreferencesController.h
//  WellDone
//
//  Created by Christian Hattinger on 12.01.10.
//  Copyright 2010 TU Wien. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BackupPreferencesController : NSMenu {
	IBOutlet NSTextField *backupPath;
}

- (IBAction)doOpen:(id)pId; 
@property (nonatomic, retain) NSTextField *backupPath;
@end

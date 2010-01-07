//
//  CoreDataBackup.h
//  WellDone
//
//  Created by Christian Hattinger on 07.01.10.
//  Copyright 2010 TU Wien. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WellDone_AppDelegate.h"

@interface CoreDataBackup : NSObject {

}

- (BOOL)backupDatabaseFile:(NSString *)backupPath error:(NSError **) error;

@end

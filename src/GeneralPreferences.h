//
//  GeneralPreferences.h
//  WellDone
//
//  Created by Alex Leutgöb on 10.01.10.
//  Copyright 2010 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SS_PreferencePaneProtocol.h"


@interface GeneralPreferences : NSViewController <SS_PreferencePaneProtocol> {
	IBOutlet NSTextField *backupPath;
}

@property (nonatomic, retain) NSTextField *backupPath;

- (IBAction)doOpen:(id)pId; 

@end

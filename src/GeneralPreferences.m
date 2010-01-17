//
//  GeneralPreferences.m
//  WellDone
//
//  Created by Alex Leutgöb on 10.01.10.
//  Copyright 2010 alexleutgoeb.com. All rights reserved.
//

#import "GeneralPreferences.h"


@implementation GeneralPreferences

@synthesize backupPath;

- (id)init {
	if (self = [super initWithNibName:@"GeneralPreferences" bundle:nil]) {
		
	}
	return self;
}

- (void)awakeFromNib {

}


#pragma mark SS_PreferencePaneProtocol methods

+ (NSArray *)preferencePanes {
    return [NSArray arrayWithObjects:[[[GeneralPreferences alloc] init] autorelease], nil];
}


- (NSView *)paneView {
    return self.view;
}


- (NSString *)paneName {
    return @"General";
}

- (NSString *)paneIdentifier {
	return @"general";
}


- (NSImage *)paneIcon {
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}


- (NSString *)paneToolTip {
    return @"General";
}


- (BOOL)allowsHorizontalResizing {
    return NO;
}


- (BOOL)allowsVerticalResizing {
    return NO;
}


#pragma mark -
#pragma mark ib actions

- (IBAction)doOpen:(id)pId; {
	
	int result;

    NSOpenPanel *oPanel = [NSOpenPanel openPanel];	
	
    [oPanel setAllowsMultipleSelection:NO];
	[oPanel setCanChooseFiles:NO];
	[oPanel setCanChooseDirectories:YES];
	
    result = [oPanel runModalForDirectory:NSHomeDirectory() file:nil types:nil];
	
	
    if (result == NSOKButton) {
		
        NSArray *filesToOpen = [oPanel filenames];
		
        NSString *aFile = [filesToOpen objectAtIndex:0];	
		NSUserDefaults *defaults = [[NSUserDefaultsController sharedUserDefaultsController] defaults];
		[defaults setObject:aFile forKey:@"backupPath"];
		[backupPath setStringValue:aFile];
	}
}

@end

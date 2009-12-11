//
//  SyncPreferences.m
//  WellDone
//
//  Created by Alex Leutgöb on 11.12.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "SyncPreferences.h"


@implementation SyncPreferences

- (id)init {
	if (self = [super initWithNibName:@"SyncPreferences" bundle:nil]) {
		
	}
	return self;
}


#pragma mark SS_PreferencePaneProtocol methods

+ (NSArray *)preferencePanes {
    return [NSArray arrayWithObjects:[[[SyncPreferences alloc] init] autorelease], nil];
}


- (NSView *)paneView {
    return self.view;
}


- (NSString *)paneName {
    return @"Sync";
}

- (NSString *)paneIdentifier {
	return @"sync";
}


- (NSImage *)paneIcon {
    return nil;
}


- (NSString *)paneToolTip {
    return @"Sync Services";
}


- (BOOL)allowsHorizontalResizing {
    return NO;
}


- (BOOL)allowsVerticalResizing {
    return NO;
}

@end

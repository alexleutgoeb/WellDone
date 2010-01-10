//
//  GeneralPreferences.m
//  WellDone
//
//  Created by Alex Leutgöb on 10.01.10.
//  Copyright 2010 alexleutgoeb.com. All rights reserved.
//

#import "GeneralPreferences.h"


@implementation GeneralPreferences

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

@end

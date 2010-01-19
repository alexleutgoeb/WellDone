//
//  FolderNameIndicatorView.m
//  WellDone
//
//  Created by Manuel Maly on 19.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FolderNameIndicatorView.h"


@implementation FolderNameIndicatorView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[[NSColor colorWithDeviceRed: (146.0/255.0) green: (108.0/255.0) blue: (65.0/255.0) alpha: 1] set];
	[NSBezierPath fillRect: dirtyRect];
}

@end

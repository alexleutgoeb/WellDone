//
//  LinkedView.m
//  WellDone
//
//  Created by Marcus S. Zarra on 3/1/08.
//  Copyright 2008 Zarra Studios LLC. All rights reserved.
//

#import "LinkedView.h"


@implementation LinkedView

@synthesize  previousView, nextView;

- (void)awakeFromNib {
    [self setWantsLayer:YES];
    [previousButton setEnabled:(previousView != nil)];
    [nextButton setEnabled:(nextView != nil)];
}

@end

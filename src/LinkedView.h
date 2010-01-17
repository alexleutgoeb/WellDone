//
//  LinkedView.h
//  WellDone
//
//  Created by Marcus S. Zarra on 3/1/08.
//  Copyright 2008 Zarra Studios LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>

@interface LinkedView : NSView {
    IBOutlet LinkedView *previousView;
    IBOutlet LinkedView *nextView;
    
    IBOutlet NSButton *nextButton;
    IBOutlet NSButton *previousButton;
}

@property (retain) LinkedView *previousView, *nextView;

@end

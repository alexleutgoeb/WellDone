//
//  ConflictResolverController.h
//  WellDone
//
//  Created by Alex Leutgöb on 17.01.10.
//  Copyright 2010 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>
#import "LinkedView.h"


@interface ConflictResolverController : NSWindowController {
    IBOutlet NSWindow *window;
    IBOutlet LinkedView *currentView;
	
	IBOutlet NSTextField *conflictTextField;
    
    CATransition *transition;
}

@property (retain) LinkedView *currentView;

- (IBAction)nextView:(id)sender;
- (IBAction)previousView:(id)sender;

- (IBAction)closeWindow:(id)sender;

@end

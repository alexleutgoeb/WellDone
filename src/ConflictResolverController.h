//
//  ConflictResolverController.h
//  WellDone
//
//  Created by Alex Leutgöb on 17.01.10.
//  Copyright 2010 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>
#import "TaskContainer.h"


@interface ConflictResolverController : NSWindowController {
    IBOutlet NSWindow *window;
	
	IBOutlet NSTextField *conflictTextField;
	IBOutlet NSTextField *conflictDetailTextField;
	IBOutlet NSButton *okButton;
	IBOutlet NSButton *cancelButton;
    
    CATransition *transition;
	
	NSArray *tasks;
}

@property (nonatomic, retain) NSArray *tasks;

- (IBAction)expandView:(id)sender;

- (IBAction)closeWindow:(id)sender;

@end

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
	IBOutlet NSBox *borderBox;
	IBOutlet NSButton *cancelSolveButton;
	IBOutlet NSButton *continueSolveButton;
	IBOutlet NSTextField *progressTextField;
	IBOutlet NSSegmentedControl *segmentedChooser;
	
	IBOutlet NSTextField *localTitle;
	IBOutlet NSTextField *remoteTitle;
	IBOutlet NSTextField *localFolder;
	IBOutlet NSTextField *remoteFolder;
	IBOutlet NSTextField *localDue;
	IBOutlet NSTextField *remoteDue;
	IBOutlet NSTextField *localTags;
	IBOutlet NSTextField *remoteTags;
	IBOutlet NSTextField *localContext;
	IBOutlet NSTextField *remoteContext;
	IBOutlet NSTextField *localRminder;
	IBOutlet NSTextField *remoteReminder;
    
	NSArray *tasks;
	
	NSInteger activeConflict;
}

@property (nonatomic, retain) NSArray *tasks;

- (IBAction)expandView:(id)sender;
- (IBAction)closeWindow:(id)sender;
- (IBAction)solveConflict:(id)sender;

@end

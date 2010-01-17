//
//  ConflictResolverController.m
//  WellDone
//
//  Created by Alex Leutgöb on 17.01.10.
//  Copyright 2010 alexleutgoeb.com. All rights reserved.
//

#import "ConflictResolverController.h"


@implementation ConflictResolverController

@synthesize tasks;

- (id)init {
	if (self = [super initWithWindowNibName:@"ConflictResolver"]) {
	}
	return self;
}

- (void)windowDidLoad {
	DLog(@"Creating conflict resolver window...");
	
    NSView *contentView = [[self window] contentView];
    [contentView setWantsLayer:YES];
	
	[conflictTextField setStringValue:[NSString stringWithFormat:@"There are %i sync conflicts.", [tasks count]]];
}

- (IBAction)expandView:(id)sender {

	NSRect frame = self.window.frame;
	frame.origin.y = frame.origin.y - 211;
	frame.size.width = 491;
	frame.size.height = 400;
	[self.window setFrame:frame display:YES animate:YES];
	[okButton setHidden:YES];
	[cancelButton setHidden:YES];
	[conflictDetailTextField setHidden:YES];
}

- (IBAction)closeWindow:(id)sender {
	[self close];
}

@end

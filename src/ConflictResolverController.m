//
//  ConflictResolverController.m
//  WellDone
//
//  Created by Alex Leutgöb on 17.01.10.
//  Copyright 2010 alexleutgoeb.com. All rights reserved.
//

#import "ConflictResolverController.h"


@implementation ConflictResolverController

@synthesize currentView;

- (id)init {
	if (self = [super initWithWindowNibName:@"ConflictResolver"]) {
		DLog(@"done");
	}
	return self;
}

- (void)windowDidLoad {
	DLog(@"Creating conflict resolver window...");
	
    NSView *contentView = [[self window] contentView];
    [contentView setWantsLayer:YES];
    [contentView addSubview:[self currentView]];
    
    transition = [CATransition animation];
    [transition setType:kCATransitionPush];
    [transition setSubtype:kCATransitionFromLeft];
    
    NSDictionary *ani = [NSDictionary dictionaryWithObject:transition forKey:@"subviews"];
    [contentView setAnimations:ani];
	
	[self.window center];
	
	[conflictTextField setStringValue:[NSString stringWithFormat:@"There are %i sync conflicts involving Tasks.", 23]];
}

- (void)setCurrentView:(LinkedView *)newView {
    if (!currentView) {
        currentView = newView;
        return;
    }
    NSView *contentView = [[self window] contentView];
    [[contentView animator] replaceSubview:currentView with:newView];
    currentView = newView;
}

- (IBAction)nextView:(id)sender {
    if (![[self currentView] nextView])
		return;
    [transition setSubtype:kCATransitionFromRight];
    [self setCurrentView:[[self currentView] nextView]];
}

- (IBAction)previousView:(id)sender {
    if (![[self currentView] previousView])
		return;
    [transition setSubtype:kCATransitionFromLeft];
    [self setCurrentView:[[self currentView] previousView]];
}

- (IBAction)closeWindow:(id)sender {
	[self close];
}

@end

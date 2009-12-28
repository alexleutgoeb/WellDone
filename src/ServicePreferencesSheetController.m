//
//  ServicePreferencesSheetController.m
//  WellDone
//
//  Created by Alex Leutgöb on 27.12.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "ServicePreferencesSheetController.h"
#import "WellDone_AppDelegate.h"
#import "SyncController.h"
#import "SyncPreferences.h"


@interface ServicePreferencesSheetController ()

- (id)initWithWindowNibName:(NSString *)windowNibName service:(NSString *)serviceIdentifier notifyingTarget:(id)inTarget;

@end


@implementation ServicePreferencesSheetController

+ (void)editService:(NSString *)serviceIdentifier onWindow:(id)parentWindow notifyingTarget:(id)inTarget {
	
	ServicePreferencesSheetController *controller;
	
	controller = [[self alloc] initWithWindowNibName:@"ServicePreferencesSheet"
											 service:serviceIdentifier
									 notifyingTarget:inTarget];
	
	if (parentWindow) {
		[NSApp beginSheet:[controller window]
		   modalForWindow:parentWindow
			modalDelegate:controller
		   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
			  contextInfo:nil];
	} else {
		[controller showWindow:nil];
	}
}

- (void)windowDidLoad {
	[workingIndicator stopAnimation:self];
}

- (id)initWithWindowNibName:(NSString *)windowNibName service:(NSString *)serviceIdentifier notifyingTarget:(id)inTarget {
	if ((self = [super initWithWindowNibName:windowNibName])) {
		serviceId = [serviceIdentifier copy];
		notifyTarget = inTarget;
	}
	return self;
}

- (void)dealloc {
	[serviceId release];	
	[super dealloc];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [sheet orderOut:nil];
}

- (IBAction)cancel:(id)sender {
	if (notifyTarget)
		[notifyTarget editServiceSheetDidEndForService:serviceId withSuccess:NO];
	[NSApp endSheet:[self window]];
}

- (IBAction)okay:(id)sender {
	[okButton setEnabled:NO];
	[usernameTextField setEnabled:NO];
	[passwordTextField setEnabled:NO];
	[workingIndicator startAnimation:self];
	[workingLabel setHidden:NO];
	
	SyncController *sc = [[NSApp delegate] sharedSyncController];
	BOOL success = [sc enableSyncService:serviceId withUser:[usernameTextField stringValue] andPwd:[passwordTextField stringValue]];
	
	if (success == NO) {
		// TODO: show error
	}
	else {
		if (notifyTarget)
			[notifyTarget editServiceSheetDidEndForService:serviceId withSuccess:YES];
		[NSApp endSheet:[self window]];
	}
}

- (void)windowWillClose:(id)sender
{
	[super windowWillClose:sender];
	[self autorelease];
}


@end

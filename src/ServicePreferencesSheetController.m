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
- (void)connectToService;

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
	[workingLabel setHidden:NO];
	[workingIndicator startAnimation:self];
	
	// TODO: option to cancel thread
	[NSThread detachNewThreadSelector:@selector(connectToService) toTarget:self withObject:nil];
}

- (void)connectToService {
	
	// TODO: check internet connection before connecting
	NSString *username = [usernameTextField stringValue];
	NSString *password = [passwordTextField stringValue];
	
	SyncController *sc = [[NSApp delegate] sharedSyncController];
	BOOL success = [sc enableSyncService:serviceId withUser:username andPwd:password];
	
	if (success == NO) {
		// TODO: show detailed error
		
		if (notifyTarget)
			[notifyTarget editServiceSheetDidEndForService:serviceId withSuccess:NO];
		[NSApp endSheet:[self window]];
		
		NSAlert *alert = [NSAlert alertWithMessageText:@"Credentials wrong." defaultButton:@"OK" 
										alternateButton:nil otherButton:nil 
										informativeTextWithFormat:@"Please check your credentials."];
		[alert runModal];
	}
	else {
		// TODO: save password in keychain
		DLog(@"Connected to service, save credentials in defaults.");
		NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];

		NSMutableDictionary *defaultServices = [NSMutableDictionary dictionaryWithDictionary:[userPreferences objectForKey:@"syncServices"]];
		
		if (defaultServices == nil)
			defaultServices = [NSMutableDictionary dictionary];
		
		NSMutableDictionary *serviceDic = [NSMutableDictionary dictionary];
		[serviceDic setObject:username forKey:@"username"];
		[serviceDic setObject:password forKey:@"password"];
		[serviceDic setObject:@"1" forKey:@"enabled"];
		
		if ([defaultServices objectForKey:serviceId] != nil) {
			if (![username isEqualToString:[[defaultServices objectForKey:serviceId] objectForKey:@"username"]]) {
				// TODO: remove remote objects with same serviceId
			}
		}
		
		[defaultServices setObject:serviceDic forKey:serviceId];
		
		[userPreferences setObject:defaultServices forKey:@"syncServices"];
		[userPreferences synchronize];
		
		if (notifyTarget)
			[notifyTarget editServiceSheetDidEndForService:serviceId withSuccess:YES];
		[NSApp endSheet:[self window]];
	}
	
	username = nil;
	password = nil;
}

- (void)windowWillClose:(id)sender {
	// [super windowWillClose:sender];
	[self autorelease];
}


@end

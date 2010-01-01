//
//  SyncPreferences.m
//  WellDone
//
//  Created by Alex Leutgöb on 11.12.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "SyncPreferences.h"
#import "WellDone_AppDelegate.h"
#import "SyncController.h"
#import "SyncService.h"
#import "ServicePreferencesSheetController.h"
#import "SFHFKeychainUtils.h"


@interface SyncPreferences ()

- (NSMutableDictionary *)syncServices;

@end

@implementation SyncPreferences

- (id)init {
	if (self = [super initWithNibName:@"SyncPreferences" bundle:nil]) {
		
	}
	return self;
}

- (void)awakeFromNib {
	NSTextFieldCell *cell = [[NSTextFieldCell alloc] init];
    [cell setFont:[NSFont boldSystemFontOfSize:13]];
	[cell setLineBreakMode:NSLineBreakByWordWrapping];
	[[tableView_accountList tableColumnWithIdentifier:@"name"] setDataCell:cell];
	[cell release];
	
	SyncController *sc = [[NSApp delegate] sharedSyncController];
	[textField_overview setStringValue:[NSString stringWithFormat:@"%i accounts, %i active", sc.servicesCount, sc.activeServicesCount]];
	
	[tableView_accountList sizeToFit];
}


#pragma mark SS_PreferencePaneProtocol methods

+ (NSArray *)preferencePanes {
    return [NSArray arrayWithObjects:[[[SyncPreferences alloc] init] autorelease], nil];
}


- (NSView *)paneView {
    return self.view;
}


- (NSString *)paneName {
    return @"Sync";
}

- (NSString *)paneIdentifier {
	return @"sync";
}


- (NSImage *)paneIcon {
    return [NSImage imageNamed:NSImageNameBonjour];
}


- (NSString *)paneToolTip {
    return @"Sync Services";
}


- (BOOL)allowsHorizontalResizing {
    return NO;
}


- (BOOL)allowsVerticalResizing {
    return NO;
}

- (void)editServiceSheetDidEndForService:(NSString *)serviceId withSuccess:(BOOL)success {
	if (success != NO) {
		// TODO: check for remote objects to delete
		SyncController *sc = [[NSApp delegate] sharedSyncController];
		[textField_overview setStringValue:[NSString stringWithFormat:@"%i service(s), %i active", sc.servicesCount, sc.activeServicesCount]];
	}
}


#pragma mark -
#pragma mark NSTableView delegate methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	return [[[[NSApp delegate] sharedSyncController] syncServices] count];
}

- (NSMutableDictionary *)syncServices {
	return [[[NSApp delegate] sharedSyncController] syncServices];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	
	if (rowIndex < 0 || rowIndex >= [[self syncServices] count]) {
		return nil;
	}
	
	SyncService *service = [[[[[NSApp delegate] sharedSyncController] syncServices] allValues] objectAtIndex:rowIndex];
	NSString *columnId = [aTableColumn identifier];
	
	if ([columnId isEqualToString:@"enabled"]) {
		return (service.isEnabled ? [NSNumber numberWithInteger:NSOnState] : [NSNumber numberWithInteger:NSOffState]);
	}
	else if ([columnId isEqualToString:@"icon"]) {
		return [NSImage imageNamed:[NSString stringWithFormat:@"%@.png", service.identifier]];
	}
	else if ([columnId isEqualToString:@"name"]) {
		return NSLocalizedString(service.identifier, @"The service identifier string.");
	}
	else if ([columnId isEqualToString:@"status"]) {
		return @"";
	}
	else {
		return nil;
	}
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	
	if (rowIndex >= 0 && rowIndex < [[self syncServices] count] && [[aTableColumn identifier] isEqualToString:@"enabled"]) {
		SyncService *service = [[[self syncServices] allValues] objectAtIndex:rowIndex]; 
		if (service.isEnabled == NO) {
			[ServicePreferencesSheetController editService:service.identifier onWindow:[[self view] window] notifyingTarget:self];
		}
		else {
			DLog(@"Service active, deactivate...");
			// Deactivate service
			SyncController *sc = [[NSApp delegate] sharedSyncController];
			BOOL success = [sc disableSyncService:service.identifier];
			
			if (success != NO) {
				DLog(@"Deactivation successful.");
				
				SyncController *sc = [[NSApp delegate] sharedSyncController];
				[textField_overview setStringValue:[NSString stringWithFormat:@"%i accounts, %i active", sc.servicesCount, sc.activeServicesCount]];

				// flag service in userdefaults as inactive
				NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
				
				NSMutableDictionary *defaultServices = [NSMutableDictionary dictionaryWithDictionary:[userPreferences objectForKey:@"syncServices"]];
				
				if (defaultServices != nil && [defaultServices objectForKey:service.identifier] != nil) {
					NSMutableDictionary *serviceDic = [NSMutableDictionary dictionaryWithDictionary:[defaultServices objectForKey:service.identifier]];
					
					// Remove password from keychain
					// save password to keychain
					NSError *error = nil;
					NSString *serviceName = [NSString stringWithFormat:@"%@ <%@>", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"], service.identifier];
					[SFHFKeychainUtils deleteItemForUsername:service.user andServiceName:serviceName error:&error];
					if (error != nil) {
						DLog(@"Error while deleting password from keychain: %@.", error);
					}
					
					// Set enabled to NO in defaults
					[serviceDic setObject:@"0" forKey:@"enabled"];
					
					[defaultServices setObject:serviceDic forKey:service.identifier];
					[userPreferences setObject:defaultServices forKey:@"syncServices"];
					[userPreferences synchronize];
					DLog(@"Changed defaults.");
				}
			}
			else {
				DLog(@"Could not deactivate service!");
			}
		}
	}
}

@end

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


#pragma mark -
#pragma mark NSTableView delegate methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	return [[[[NSApp delegate] sharedSyncController] syncServices] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	
	if (rowIndex < 0 || rowIndex >= [[[[NSApp delegate] sharedSyncController] syncServices] count]) {
		return nil;
	}
	
	SyncService *service = [[[[[NSApp delegate] sharedSyncController] syncServices] allValues] objectAtIndex:rowIndex];
	NSString *columnId = [aTableColumn identifier];
	
	if ([columnId isEqualToString:@"enabled"]) {
		return nil;
	}
	else if ([columnId isEqualToString:@"icon"]) {
		return [NSImage imageNamed:[NSString stringWithFormat:@"%@.png", service.identifier]];
	}
	else if ([columnId isEqualToString:@"name"]) {
		return service.identifier;
	}
	else if ([columnId isEqualToString:@"status"]) {
		return @"";
	}
	else {
		return nil;
	}
}

@end

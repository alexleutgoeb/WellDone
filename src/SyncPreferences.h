//
//  SyncPreferences.h
//  WellDone
//
//  Created by Alex Leutgöb on 11.12.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GtdApi.h"
#import "SS_PreferencePaneProtocol.h"


@interface SyncPreferences : NSViewController <SS_PreferencePaneProtocol> {
@private
    IBOutlet NSScrollView *scrollView_accountList;
    IBOutlet NSTableView *tableView_accountList;
	IBOutlet NSButton *button_editService;
	IBOutlet NSTextField *textField_overview;	
}

// - (void)editService:(id<GtdApi> *)aService;
// - (IBAction)editSelectedService:(id)sender;
// - (void)updateServiceOverview;
// - (void)updateControlAvailability;
// - (NSString *)statusMessageForService:(id<GtdApi> *)aService;

@end

//
//  ServicePreferencesSheetController.h
//  WellDone
//
//  Created by Alex Leutgöb on 27.12.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ServicePreferencesSheetController : NSWindowController {
@private
	// window outlets
	IBOutlet NSTextField *usernameTextField;
	IBOutlet NSSecureTextField *passwordTextField;
	IBOutlet NSButton *cancelButton;
	IBOutlet NSButton *okButton;
	
	// current config
	id notifyTarget;
	NSString *serviceId;
}

+ (void)editService:(NSString *)serviceIdentifier onWindow:(id)parentWindow notifyingTarget:(id)inTarget;
- (IBAction)cancel:(id)sender;
- (IBAction)okay:(id)sender;

@end

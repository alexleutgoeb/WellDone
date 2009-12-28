//
//  ServicePreferencesSheetController.h
//  WellDone
//
//  Created by Alex Leutgöb on 27.12.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/**
 ServicePreferencesSheetController class
 Controller class handles actions on the ServicePreferencesSheet view.
*/
@interface ServicePreferencesSheetController : NSWindowController {
@private
	// window outlets
	IBOutlet NSTextField *usernameTextField;
	IBOutlet NSSecureTextField *passwordTextField;
	IBOutlet NSButton *cancelButton;
	IBOutlet NSButton *okButton;
	IBOutlet NSProgressIndicator *workingIndicator;
	IBOutlet NSTextField *workingLabel;
	
	// current config
	id notifyTarget;
	NSString *serviceId;
}

/**
 Static method adding a modal window for entering credentials for a service to the
 given parentWindow.
 @param serviceIdentifier identifier of the service which should be edited
 @param parentWindow window to which the modal view should be added
 @param inTarget target to notify about changes in modal view
*/
+ (void)editService:(NSString *)serviceIdentifier onWindow:(id)parentWindow notifyingTarget:(id)inTarget;

/**
 Called if the cancel button of the view get pressed.
*/
- (IBAction)cancel:(id)sender;

/**
 Called if the ok button of the view get pressed.
*/
- (IBAction)okay:(id)sender;

@end

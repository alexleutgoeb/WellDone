//
//  HUDTaskEditorController.h
//  WellDone
//
//  Created by Manuel Maly on 11.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SimpleListController.h"


typedef enum _repeatValue
{
	never = 0, daily, weekly, monthly
} repeatValue;


@interface HUDTaskEditorController : NSWindowController {
	IBOutlet NSObjectController* taskObjectController;
	IBOutlet NSTextView* note;
	IBOutlet NSTextField* datedue;
	IBOutlet SimpleListController *simpController;
	
	IBOutlet NSTextField* estimatedWorkingTime;
}

- (IBAction)setRepeat:(id)sender;

@property (nonatomic, retain) NSTextField* datedue;
@property (nonatomic, retain) SimpleListController *simpController;


@end

//
//  MainWindowController.h
//  WellDone
//
//  Created by Manuel Maly on 13.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SimpleListController.h";
#import "GTDListController.h";
#import "TaskEditorController.h"

@interface MainWindowController : NSWindowController {
	IBOutlet NSView *targetView;
	SimpleListController *simpleListController;
	GTDListController *gtdListController;
	TaskEditorController *taskeditorController;
}


@end

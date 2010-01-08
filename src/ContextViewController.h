//
//  ContextViewController.h
//  WellDone
//
//  Created by Andrea F. on 07.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Context.h"
#import "SimpleListController.h"

@interface ContextViewController : NSViewController {
	IBOutlet NSTableView* myview;
	IBOutlet NSArrayController* arrayController;
	
	SimpleListController *simpController;
}

- (void)contextsSelectionChanged:(id)sender;

@property (nonatomic, retain) SimpleListController *simpController;

@end

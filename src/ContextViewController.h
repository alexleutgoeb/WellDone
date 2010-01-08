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
	IBOutlet NSTableView* myTableView;
	IBOutlet NSArrayController* arrayController;
	IBOutlet NSButton* checkBoxFilter;
	
	SimpleListController *simpController;
}

- (void)contextsSelectionChanged;
- (IBAction)toggleFilteringByContext:(id)sender;

@property (nonatomic, retain) SimpleListController *simpController;

@end

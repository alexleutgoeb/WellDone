//
//  SidebarFolderController.h
//  WellDone
//
//  Created by Manuel Maly on 06.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SidebarFolderTreeView.h"


@interface SidebarFolderController : NSViewController {
	IBOutlet SidebarFolderTreeView *sidebar;
}

- (IBAction)addChild: (id)sender;

@end

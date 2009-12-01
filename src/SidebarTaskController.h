//
//  SidebarTaskController.h
//  WellDone
//
//  Created by Dominik Hofer on 16/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SidebarTaskController : NSViewController {
	IBOutlet NSObjectController* taskObjectController;
	IBOutlet NSTextField* note;
}

@end

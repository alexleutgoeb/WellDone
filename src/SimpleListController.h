//
//  SimpleListController.h
//  WellDone
//
//  Created by Manuel Maly on 13.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SimpleListController : NSViewController {
	IBOutlet NSTreeController* treeController;
	IBOutlet NSOutlineView* myview;
}

- (id)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item;
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item;

@end

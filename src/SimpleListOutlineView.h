//
//  SimpleListOutlineView.h
//  WellDone
//
//  Created by Dominik Hofer on 23/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SimpleListOutlineView : NSOutlineView {

}

- (void)keyDown:(NSEvent *)theEvent;
- (NSMenu*)menuForEvent:(NSEvent*)evt;
- (NSMenu*)defaultMenuForRow:(int)row;
- (BOOL)isRowDeletable:(int)row;
- (void)contextMenuDeleteTask: (id)sender;

@end

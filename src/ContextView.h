//
//  ContextView.h
//  WellDone
//
//  Created by Andrea F. on 14.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ContextView : NSTableView{

}

- (void)keyDown:(NSEvent *)theEvent;
- (NSMenu*)menuForEvent:(NSEvent*)evt;
- (NSMenu*)defaultMenuForRow:(int)row;
- (BOOL)isRowDeletable:(int)row;
- (void)contextMenuDeleteContext: (id)sender;

@end

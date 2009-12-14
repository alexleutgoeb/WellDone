//
//  SimpleListController.h
//  WellDone
//
//  Created by Manuel Maly on 13.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Task.h>


@interface SimpleListController : NSViewController {
	IBOutlet NSTreeController* treeController;
	IBOutlet NSOutlineView* myview;
	NSManagedObjectContext *moc;
}

@property (nonatomic, retain, readonly) NSTreeController *treeController;
- (id)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item;
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item;
- (void)setTaskDone:(NSTextFieldCell*)cell;
- (void)setTaskUndone:(NSTextFieldCell*)cell;
- (NSArray *) getCurrentTags;
- (Tag *) getTagByName: (NSString *)tagName;
- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString: (NSString *)editingString;
@end

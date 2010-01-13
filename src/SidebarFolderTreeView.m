//
//  SidebarNode.m
//  Sidebar
//
//  Created by Matteo Bertozzi on 3/8/09.
//  Copyright 2009 Matteo Bertozzi. All rights reserved.
//
#import <SidebarBadgeCell.h>
#import <SidebarFolderTreeView.h>
#import <Task.h>
#import <Folder.h>
#import <SidebarFolderNode.h>

#define kSidebarPBoardType		@"SidebarNodePBoardType"
#define rootNodeInbox			@"1"
#define nodeInbox				@"1.1"
#define rootNodeTaskFolders		@"2"

@implementation SidebarFolderTreeView

#pragma mark -
#pragma mark Initializing Code

/* ============================================================================
 *  Initializing Code, should be run when view is instantiated
 */

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	_contents = [[NSMutableDictionary alloc] init];
	_roots = [[NSMutableArray alloc] init];
	_defaultActionTarget = nil;
	_defaultAction = NULL;
	
	// Scroll to the top in case the outline contents is very long
	[[[self enclosingScrollView] verticalScroller] setFloatValue:0.0];
	[[[self enclosingScrollView] contentView] scrollToPoint:NSMakePoint(0, 0)];
	[self setBackgroundColor:[NSColor colorWithCalibratedRed:0.72 green:0.74 blue:0.79 alpha:1.0]];
	
	[self setFocusRingType:NSFocusRingTypeNone];
	
	// Make outline view appear with gradient selection, and behave like the Finder, iTunes, etc.
	[self setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
	
	// drag and drop support
	[self registerForDraggedTypes:[NSArray arrayWithObjects:kSidebarPBoardType, nil]];
	
	
	
	return self;
}


- (void)setViewController:(NSViewController *)newController
{
    if (newController)
    {
		myController = newController;
    }
}


#pragma mark -
#pragma mark Add Root Folder to View


/* ============================================================================
 *  Add Root Folder to View
 */

/*
 * Adds a new root folder (node) to the view.
 */
- (void)addSection:(id)key
		   caption:(NSString *)folderCaption
{
	if ([_contents objectForKey:key] != nil)
		[self removeItem:key];
	
	// Create and Setup Node
	SidebarFolderNode *node = [[SidebarFolderNode alloc] init];
	[node setNodeType:kSidebarNodeTypeSection];
	[node setCaption:folderCaption];
	[node setNodeKey:key];
	
	// Add Object to List
	[_contents setObject:node forKey:key];
	[_roots addObject:node];
	//[node release];
}

#pragma mark -
#pragma mark Add Child(ren) Folder to View

/* ============================================================================
 *  Add Child(ren) Folder to View
 */

- (void)addChild:(id)parentKey
			 key:(id)key
			 url:(NSString *)url
{
	[self addChild:parentKey key:key url:url action:NULL target:nil];
}

- (void)addChild:(id)parentKey
			 key:(id)key
			 url:(NSString *)url
		  action:(SEL)aSelector
		  target:(id)target
{
	NSString *caption = [[NSFileManager defaultManager] displayNameAtPath:url];
	NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:url];
	
	[self addChild:parentKey
			   key:key
		   caption:caption
			  icon:icon
			  data:url
			action:aSelector target:target];
}

- (void)addChild:(id)parentKey
			 key:(id)key
		 caption:(NSString *)childCaption
			icon:(NSImage *)childIcon
{
	[self addChild:parentKey
			   key:key
		   caption:childCaption
			  icon:childIcon
			  data:nil
			action:NULL target:nil];
}

- (void)addChild:(id)parentKey
			 key:(id)key
		 caption:(NSString *)childCaption
			icon:(NSImage *)childIcon
		  action:(SEL)aSelector
		  target:(id)target
{
	[self addChild:parentKey
			   key:key
		   caption:childCaption
			  icon:childIcon
			  data:nil
			action:aSelector target:target];
}

- (void)addChild:(id)parentKey
			 key:(id)key
		 caption:(NSString *)childCaption
			icon:(NSImage *)childIcon
			data:(id)data
{
	[self addChild:parentKey
			   key:key
		   caption:childCaption
			  icon:childIcon
			  data:data
			action:NULL target:nil];
}

- (void)addChild:(id)parentKey
			 key:(id)key
		 caption:(NSString *)childCaption
			icon:(NSImage *)childIcon
			data:(id)data
		  action:(SEL)aSelector
		  target:(id)target
{
	// Create and Setup Node
	SidebarFolderNode *node = [[SidebarFolderNode alloc] init];
	[node setAction:aSelector target:target];
	[node setNodeType:kSidebarNodeTypeItem];
	[node setCaption:childCaption];
	[node setParentKey:parentKey];
	[node setIcon:childIcon];
	[node setNodeKey:key];
	
	// Add Node as Child of Root Node
	SidebarFolderNode *parentNode = [_contents objectForKey:parentKey];
	if (parentNode != nil)
		[parentNode addChild:node];
	else
		[_roots addObject:node];
	
	[node setData:data];
	
	// Add Object to List
	[_contents setObject:node forKey:key];

	//[node release];
}

#pragma mark -
#pragma mark Insert Child Folder to View

/* ============================================================================
 *  Insert Child Folder to View
 */
- (void)insertChild:(id)parentKey
				key:(id)key
			atIndex:(NSUInteger)index
				url:(NSString *)url
			 action:(SEL)aSelector
			 target:(id)target
{
	NSString *caption = [[NSFileManager defaultManager] displayNameAtPath:url];
	NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:url];
	
	[self insertChild:parentKey
				  key:key
			  atIndex:index
			  caption:caption
				 icon:icon
				 data:url
			   action:aSelector target:target];
}

- (void)insertChild:(id)parentKey
				key:(id)key
			atIndex:(NSUInteger)index
			caption:(NSString *)childCaption
			   icon:(NSImage *)childIcon
			 action:(SEL)aSelector
			 target:(id)target
{
	[self insertChild:parentKey
				  key:key
			  atIndex:index
			  caption:childCaption
				 icon:childIcon
				 data:nil
			   action:aSelector target:target];
}

- (void)insertChild:(id)parentKey
				key:(id)key
			atIndex:(NSUInteger)index
			caption:(NSString *)childCaption
			   icon:(NSImage *)childIcon
			   data:(id)data
			 action:(SEL)aSelector
			 target:(id)target
{
	// Create and Setup Node
	SidebarFolderNode *node = [[SidebarFolderNode alloc] init];
	[node setAction:aSelector target:target];
	[node setNodeType:kSidebarNodeTypeItem];
	[node setCaption:childCaption];
	[node setParentKey:parentKey];
	[node setIcon:childIcon];
	[node setNodeKey:key];
	
	// Add Node as Child of Root Node
	SidebarFolderNode *parentNode = [_contents objectForKey:parentKey];
	if (parentNode != nil)
		[parentNode insertChild:node atIndex:index];
	else
		[_roots addObject:node];
	
	// Add Object to List
	[_contents setObject:node forKey:key];
	//[node release];
}

#pragma mark -
#pragma mark Remove Items from View

/* ============================================================================
 *  Remove Items from View
 */

- (void)removeItem:(id)key {
	SidebarFolderNode *node = [_contents objectForKey:key];
	if (node == nil) return;
	
	id parentKey = [node parentKey];
	if (parentKey != nil) {
		SidebarFolderNode *parentNode = [_contents objectForKey:parentKey];
		[parentNode removeChild:node];
	} else {
		[_roots removeObject:node];
	}
	
	[_contents removeObjectForKey:key];
}

- (void)removeChild:(id)key {
	[self removeItem:key];
}

- (void)removeSection:(id)key {
	[self removeItem:key];
}

#pragma mark -
#pragma mark Selection of Items

/* ============================================================================
 *  Selection of Items
 */

- (SidebarFolderNode *)selectedNode {
	return([self itemAtRow:[self selectedRow]]);
}

/*
 * Returns the currently selected folder. If there is no selection, or the selection
 * is not a folder, NIL is returned.
 */
- (Folder *)selectedFolder {
	id *selectedNode = [self selectedNode];
	if ([[selectedNode data] isKindOfClass: [Folder class]]) {
		return [selectedNode data];
	}
	return nil;
}

- (void)selectItem:(id)key {
	SidebarFolderNode *node = [_contents objectForKey:key];
	if (node != nil && [node nodeType] != kSidebarNodeTypeSection) {
		NSInteger rowIndex = [self rowForItem:node];
		NSIndexSet *set = [NSIndexSet indexSetWithIndex:rowIndex];
		if (rowIndex >= 0) [self selectRowIndexes:set byExtendingSelection:NO];
		NSLog(@"Selected row with index: %d", rowIndex);
	}
}

- (void)unselectItem {
}

#pragma mark -
#pragma mark Expand/Collapse of Items

/* ============================================================================
 *  Expand/Collapse of Items
 */

- (void)expandAll {
	[super expandItem:nil expandChildren:YES];
}

- (void)expandItem:(id)key {
	if (key == nil || [key isKindOfClass:[SidebarFolderNode class]]) {
		[super expandItem:key];
	} else {
		SidebarFolderNode *node = [_contents objectForKey:key];
		if (node != nil && [node nodeType] != kSidebarNodeTypeItem)
			[super expandItem:node expandChildren:NO];
	}
}

- (void)expandItem:(id)key expandChildren:(BOOL)expandChildren {
	if (key == nil || [key isKindOfClass:[SidebarFolderNode class]]) {
		[super expandItem:key expandChildren:expandChildren];
	} else {
		SidebarFolderNode *node = [_contents objectForKey:key];
		if (node != nil && [node nodeType] != kSidebarNodeTypeItem)
			[super expandItem:node expandChildren:expandChildren];
	}
}

- (void)collapseAll {
	[super collapseItem:nil collapseChildren:YES];
}

- (void)collapseItem:(id)key {
	if (key == nil || [key isKindOfClass:[SidebarFolderNode class]]) {
		[super collapseItem:key];
	} else {
		SidebarFolderNode *node = [_contents objectForKey:key];
		if (node != nil && [node nodeType] != kSidebarNodeTypeItem)
			[super collapseItem:node collapseChildren:NO];
	}
}

- (void)collapseItem:(id)key expandChildren:(BOOL)collapseChildren {
	if (key == nil || [key isKindOfClass:[SidebarFolderNode class]]) {
		[super collapseItem:key collapseChildren:collapseChildren];
	} else {
		SidebarFolderNode *node = [_contents objectForKey:key];
		if (node != nil && [node nodeType] != kSidebarNodeTypeItem)
			[super collapseItem:node collapseChildren:collapseChildren];
	}
}

#pragma mark -
#pragma mark Badges

/* ============================================================================
 *  Badges
 */
- (void)setBadge:(id)key count:(NSInteger)badgeValue {
	SidebarFolderNode *node = [_contents objectForKey:key];
	[node setBadgeValue:badgeValue];
}

- (void)unsetBadge:(id)key {
	SidebarFolderNode *node = [_contents objectForKey:key];
	[node unsetBadgeValue];
}

#pragma mark -
#pragma mark Delegate: Data Source

/* ============================================================================
 *  Delegate: Data Source
 */

/*
 * The child item at index of a item. 
 * If item is nil, returns the appropriate child item of the root object.
 */ 
- (id)outlineView:(NSOutlineView *)outlineView 
			child:(NSInteger)index
		   ofItem:(id)item
{
	if (item == nil)
		return [_roots objectAtIndex:index];
	return [item childAtIndex:index];
}

/*
 * Returns a Boolean value that indicates whether in a given item is expandable.
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item
{
	return((item == nil) ? NO : [item nodeType] != kSidebarNodeTypeItem);
}

/*
 * Returns the number of child items encompassed by a given item.
 */
- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item
{
	return((item == nil) ? [_roots count] : [item numberOfChildren]);
}

/*
 * Invoked by outlineView to return the data object 
 * associated with the specified item.
 */
- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
		   byItem:(id)item
{
	return [item caption];
}

#pragma mark -
#pragma mark Delegate: NSOutlineView

/* ============================================================================
 * Delegate: NSOutlineView 
 */

- (BOOL)outlineView:(NSOutlineView *)outlineView
   shouldSelectItem:(id)item
{
	return([item nodeType] != kSidebarNodeTypeSection);
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView
 dataCellForTableColumn:(NSTableColumn *)tableColumn
				   item:(id)item
{
	return [tableColumn dataCell];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
shouldEditTableColumn:(NSTableColumn *)tableColumn
			   item:(id)item
{
	return YES;
}

-(BOOL)outlineView:(NSOutlineView*)outlineView
	   isGroupItem:(id)item
{
	return([item nodeType] != kSidebarNodeTypeItem);
}

- (void)outlineView:(NSOutlineView *)outlineView
    willDisplayCell:(NSCell*)cell
     forTableColumn:(NSTableColumn *)tableColumn
               item:(id)item
{
	if ([item isKindOfClass:[SidebarFolderNode class]]) {
		if([item data] == nil) {
			[cell setEditable:NO];
		}
		else {
			[cell setEditable:YES];
		}

	}
	if ([cell isKindOfClass:[SidebarBadgeCell class]]) {
		SidebarBadgeCell *badgeCell = (SidebarBadgeCell *) cell;
		[badgeCell setBadgeCount:[item badgeValue]];
		[badgeCell setHasBadge:[item hasBadge]];
		[badgeCell setIcon:[item icon]];
	}
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	SidebarFolderNode *selectedNode = [self selectedNode];
	if (selectedNode == nil) return;
	
	SEL action = NULL;
	id target = nil;
	
	if ([selectedNode hasAction]) {
		action = [selectedNode action];
		target = [selectedNode actionTarget];
	} else {
		action = _defaultAction;
		target = _defaultActionTarget;
	}
	
	// Run Thread with selected Action
	if (action != NULL) {
		[target performSelector:action withObject:selectedNode];
	}
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
	return([[fieldEditor string] length] > 0);
}

- (void)outlineView:(NSOutlineView *)outlineView 
	 setObjectValue:(id)object 
	 forTableColumn:(NSTableColumn *)tableColumn 
			 byItem:(id)item {
	
	if ([item isKindOfClass: [SidebarFolderNode class]]) {
		
		NSLog(@"Will save new name for folder: %@", [item caption]);
		
		if ([item data] != nil && [[item data] isKindOfClass: [Folder class]]) {
			SidebarFolderNode *node = item;
			Folder *folderToChange = [node data];
			[folderToChange setName:object];
			[myController saveChangesToStore];
			
			// Set caption on folder node in view
			[node setCaption:object];
		}
		

	}
	


}

#pragma mark -
#pragma mark Delegate: Drag & Drop

/* ============================================================================
 *  Delegate: Drag & Drop
 */

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal {
	return NSDragOperationMove;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
         writeItems:(NSArray *)items
       toPasteboard:(NSPasteboard *)pboard
{
	[pboard declareTypes:[NSArray arrayWithObjects:kSidebarPBoardType, nil] owner:self];
	
	// keep track of this nodes for drag feedback in "validateDrop"
	dragNodesArray = items;
	
	// currently only 1-item drags are supported:
	SidebarFolderNode *draggedItem = [dragNodesArray lastObject];
	id draggedItemParentKey = [draggedItem parentKey];
	
	// dragged item is not a root node (root nodes have nil as parent key)
	if (draggedItemParentKey != nil) {	
		SidebarFolderNode *parentNode = [self nodeForKey:draggedItemParentKey];
		allowedDragDestinations = [NSMutableArray arrayWithCapacity:([parentNode numberOfChildren]+1)];
		[allowedDragDestinations addObject:parentNode];
		NSEnumerator *enumerator = [parentNode childrenEnumeration];
		id child;
		while ((child = [enumerator nextObject]) != nil) {
			[allowedDragDestinations addObject:child];
		}
	}
	else {	
		allowedDragDestinations = [NSMutableArray arrayWithCapacity:0];
	}
	

	
	return YES;
}

/*
 * Checks, wether the proposed drag destination is ok for a dragged item.
 * Currently, only drags to the root node are disabled.
 */
- (NSDragOperation)outlineView:(NSOutlineView *)outlineView
                  validateDrop:(id<NSDraggingInfo>)info
                  proposedItem:(id)item
            proposedChildIndex:(NSInteger)index
{

	
	if (item == nil) {
		//NSLog(@"Tried to drag item to root note - won't let that happen...");
		return NSDragOperationNone;
	}
	NSLog(@"proposedItem: %@, index: %d", [item caption], index);
	if (![item isDraggable] && index >= 0) {
		if ([allowedDragDestinations containsObject:item])
			return NSDragOperationMove;
	}
		
	return NSDragOperationNone;
}

/*
 * This is called when a drag&drop operation is ended (user releases mouse). Currently, only drags within the outline view
 * are handled.
 */
- (BOOL)outlineView:(NSOutlineView*)outlineView
		 acceptDrop:(id<NSDraggingInfo>)info
			   item:(id)targetItem
		 childIndex:(NSInteger)index {
	NSPasteboard *pboard = [info draggingPasteboard];	// get the pasteboard
	
	// user is doing an intra-app drag within the outline view
	if ([pboard availableTypeFromArray:[NSArray arrayWithObject:kSidebarPBoardType]]) {
		id targetKey = (targetItem != nil) ? [targetItem nodeKey] : nil;
		
		for (NSInteger i = 0; i < [dragNodesArray count]; ++i) {
			SidebarFolderNode *node = [dragNodesArray objectAtIndex:i];
			
			// Get Adjust Index Value
			NSInteger adjIdx = 0;
			if (targetKey != nil && [node parentKey] == targetKey && [targetItem indexOfChild:node] < index)
				adjIdx = -1;
			
			// Remove From Current Position
			if ([node parentKey] != nil) {
				SidebarFolderNode *parentNode = [_contents objectForKey:[node parentKey]];
				[parentNode removeChild:node];
			} else {
				[_roots removeObject:node];
			}
			
			// Update Parent Key && Insert Item at New Location
			[node setParentKey:targetKey];
			if (targetKey != nil) {
				[((SidebarFolderNode *)targetItem) insertChild:node atIndex:(index + i + adjIdx)];
			} else if (index < 0) {
				[_roots addObject:node];
			} else {
				[_roots insertObject:node atIndex:index];
			}	
			[myController saveFolderOrderingToStore];
			
			[self reloadData];
			
			if ([[node data] isKindOfClass: [Folder class]]) {
				[self selectItem:[[node data] objectID]];
			}
		}
		
		
		return YES;
	}
	
	return NO;
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event
					   inRect:(NSRect)cellFrame
					   ofView:(NSView *)controlView {
	if ([controlView isKindOfClass:[SidebarFolderTreeView class]]) {
		SidebarFolderTreeView *sidebar = (SidebarFolderTreeView *) controlView;
		SidebarFolderNode *node = [sidebar selectedNode];
		if (![node isDraggable])
			return NSCellHitTrackableArea;
	}
	
	return NSCellHitContentArea;
}

#pragma mark -
#pragma mark Delegate: Custom Drawing

/* ============================================================================
 *  Custom Drawing
 */

/*
 * Set better apple-matching colors.
 */
- (void)drawRect:(NSRect)rect {
	BOOL isWindowFront = [[NSApp mainWindow] isVisible];
	if(isWindowFront){
		[self setBackgroundColor:[NSColor colorWithCalibratedRed:214.0/255.0 green:221.0/255.0 blue:229.0/255.0 alpha:1.0]];
	}else{
		[self setBackgroundColor:[NSColor colorWithCalibratedRed:232.0/255.0 green:232.0/255.0 blue:232.0/255.0 alpha:1.0]];
	}
	[super drawRect:rect];
}

#pragma mark -
#pragma mark Context Menu

/* ============================================================================
 *  Context menu
 */

-(NSMenu*)menuForEvent:(NSEvent*)evt 
{
    NSPoint pt = [self convertPoint:[evt locationInWindow] fromView:nil];
    int row=[self rowAtPoint:pt];
    return [self defaultMenuForRow:row];
}

-(NSMenu*)defaultMenuForRow:(int)row
{
    //Uncomment this to highlight the current row if the user right-clicks onto a folder
	//Currently, that is not seen as good behaviour.
	/*
	id item = [self itemAtRow:row];
	if ([item isKindOfClass: [SidebarFolderNode class]]) {
		if ([item data] != nil)
			[self selectItem: [[item data] objectID]];
	}*/
	
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Folder menu"];

	if ([self mayAddFolderToRow:row]) {
		NSMenuItem *addItem = [NSMenuItem alloc];
		[addItem initWithTitle:@"Add Folder" action:@selector(contextMenuAddFolder:) keyEquivalent: @""];
		[theMenu addItem:addItem];
	}
	if ([self isRowDeletable:row]) {
		NSMenuItem *deleteItem = [NSMenuItem alloc];
		[deleteItem initWithTitle:@"Delete Folder" action:@selector(contextMenuDeleteFolder:) keyEquivalent: @""];
		[deleteItem setRepresentedObject:[self itemAtRow:row]];
		
		//Uncomment for CMD+Backspace key equivalent (seems not to work now, for whatever reason)
		/*const unichar backspace = 0x0008;
		[deleteItem setKeyEquivalent:[NSString stringWithCharacters:&backspace length:1]];
		[deleteItem setKeyEquivalentModifierMask:NSCommandKeyMask];*/
		
		[theMenu addItem:deleteItem];
	}
	
	if ([[theMenu itemArray] count] == 0)
		return nil;

    // you'll need to find a way of getting the information about the 
    // row that is to be removed to the removeSite method
    // assuming that an ivar 'contextRow' is used for this
    //contextRow = row;
	
    return theMenu;        
}

-(BOOL) isRowDeletable:(int)row {
	if (row == -1) return NO;
	id item = [self itemAtRow:row];
	if ([item isKindOfClass: [SidebarFolderNode class]]) {
		if ([item data] != nil)
			return YES;
	}
	return NO;
}

-(BOOL) mayAddFolderToRow:(int)row {
	if (row == -1) return YES;
	id item = [self itemAtRow:row];
	if ([item isKindOfClass: [SidebarFolderNode class]]) {
		if ([item data] != nil)
			return YES;
		if ([item nodeKey] == rootNodeTaskFolders)
			return YES;
	}
	return NO;
}

#pragma mark -
#pragma mark Other

/* ============================================================================
 *  Other
 */

- (void)setDefaultAction:(SEL)action target:(id)target {
	_defaultAction = action;
	_defaultActionTarget = target;
}

- (SidebarFolderNode *) nodeForKey:(id)key {
	return [_contents objectForKey:key];
}

- (void) contextMenuAddFolder: (id)sender {
	[myController addNewFolderByContextMenu];
}

-(void) contextMenuDeleteFolder: (id)sender {
	NSLog(@"Delete sender: %@", sender);
	id representedObject = [sender representedObject];
	NSLog(@"Represented object: %@", representedObject);
	if ([representedObject isKindOfClass:[SidebarFolderNode class]]) {
		//NSLog(@"Represented object data: %@", [representedObject data]);
		[myController deleteFolderByContextMenu:[representedObject data]];
	}
	
}

@end


//
//  SidebarNode.m
//  Sidebar
//
//  Created by Matteo Bertozzi on 3/8/09.
//  Copyright 2009 Matteo Bertozzi. All rights reserved.
//

#import "SidebarBadgeCell.h"
#import "SidebarFolderNode.h"
#import "SidebarFolderTreeView.h"
#import <Task.h>

#define kSidebarPBoardType		@"SidebarNodePBoardType"
#define rootNodeTaskFolders		@"1"

@implementation SidebarFolderTreeView

/* ============================================================================
 *  PUBLIC Constructors/Distructors
 */
- (void)dealloc {
	[_contents release];
	[_roots release];
	
	[super dealloc];
}

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
	
	// Make outline view appear with gradient selection, and behave like the Finder, iTunes, etc.
	[self setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
	
	// drag and drop support
	[self registerForDraggedTypes:[NSArray arrayWithObjects:kSidebarPBoardType, nil]];
	
	// Sub Delegates & Data Source
	[self setDataSource:self];
	[self setDelegate:self];
	
	// Insert initial root nodes
	[self initializeRootNodes];
	
	// Initialize listening to notifications by managedObjectContext
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
		   selector:@selector(reactToMOCUpdate:)
			   name:NSManagedObjectContextObjectsDidChangeNotification
			 object:nil];
	
	return self;
}

/*
 * Initialize all root nodes which group items in the source list view.
*/
- (void) initializeRootNodes {
	[self addSection:rootNodeTaskFolders caption:@"FOLDERS"];
	
	/*
	NSManagedObjectContext * moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];

	
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Folder" inManagedObjectContext:moc];
	
		
	Folder *folder = [[Folder alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
	folder.name =@"TestFolder";
	[self addNewFolderEntity:folder toSection:rootNodeTaskFolders];
	*/
	
	[self reloadData];
	[self expandItem:rootNodeTaskFolders];
	
	//TODO: Insert more sections
}

/*
 * This method will be called when any update is done to the managedObjectContext.
 * It reacts to some of these changes with updates to the folder tree view.
*/
- (void) reactToMOCUpdate:(NSNotification *)notification {
	//NSEnumerator *enumerator = [[notification object]
	//							objectEnumerator];
	id object;
	NSDictionary *userInfo = [notification userInfo];
	
	NSEnumerator *updatedObjects = [[userInfo objectForKey:NSUpdatedObjectsKey] objectEnumerator];
	while (object = [updatedObjects nextObject]) {
		if ([object isKindOfClass: [Folder class]]) {
			NSLog(@"Updated Folder with name: %@", [object name]);
			// TODO: handle updated objects
			// TODO: handle deleted objects (flag: delete), they are not really deleted until synchronisation
		}
	}
	
	NSEnumerator *insertedObjects = [[userInfo objectForKey:NSInsertedObjectsKey] objectEnumerator];
	while (object = [insertedObjects nextObject]) {
		if ([object isKindOfClass: [Folder class]]) {
			NSLog(@"Inserted Folder with name: %@", [object name]);
			[self addNewFolderEntity:object toSection:rootNodeTaskFolders];
			[self reloadData];			
		}
	}
	
	NSEnumerator *deletedObjects = [[userInfo objectForKey:NSDeletedObjectsKey] objectEnumerator];
	while (object = [deletedObjects nextObject]) {
		if ([object isKindOfClass: [Folder class]]) {
			NSLog(@"Deleted Folder with name: %@", [object name]);
			[self removeFolderEntity: object];
		}
	}
}

- (void) addNewFolderEntity:(Folder *) folder toSection:(NSString *)section {
	if([[folder objectID] isTemporaryID] == YES) {
		NSLog(@"New Folder has temporary objectid!");
	}
	
	[self addChild:section 
			 key:[folder name]  // TODO: change to real unique key!
			 caption:[folder name]
			 icon:[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)]
			 action:@selector(buttonPres:) 
			 target:self];
}

- (void) removeFolderEntity:(Folder *) folder {
	[self removeItem: [folder name]];  // TODO: change to real unique key!
}

- (void)setDefaultAction:(SEL)action target:(id)target {
	_defaultAction = action;
	_defaultActionTarget = target;
}

/* ============================================================================
 *  PUBLIC Methods (Add Root Folder)
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
	[node release];
}

/* ============================================================================
 *  PUBLIC Methods (Add Child)
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
	SidebarFolderNode *rootNode = [_contents objectForKey:parentKey];
	if (rootNode != nil)
		[rootNode addChild:node];
	else
		[_roots addObject:node];
	
	[node setData:data];
	
	// Add Object to List
	[_contents setObject:node forKey:key];

	[node release];
}

/* ============================================================================
 *  PUBLIC Methods (Insert Child)
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
	SidebarFolderNode *rootNode = [_contents objectForKey:parentKey];
	if (rootNode != nil)
		[rootNode insertChild:node atIndex:index];
	else
		[_roots addObject:node];
	
	// Add Object to List
	[_contents setObject:node forKey:key];
	[node release];
}

/* ============================================================================
 *  PUBLIC Methods (Remove Items)
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

- (void)removeFolder:(id)key {
	[self removeItem:key];
}

- (void)removeSection:(id)key {
	[self removeItem:key];
}

/* ============================================================================
 *  PUBLIC Methods (Selection)
 */
- (SidebarFolderNode *)selectedNode {
	return([self itemAtRow:[self selectedRow]]);
}

- (void)selectItem:(id)key {
	SidebarFolderNode *node = [_contents objectForKey:key];
	if (node != nil && [node nodeType] != kSidebarNodeTypeSection) {
		NSInteger rowIndex = [self rowForItem:node];
		if (rowIndex >= 0) [self selectRow:rowIndex byExtendingSelection:NO];
	}
}

- (void)unselectItem {
}

/* ============================================================================
 *  PUBLIC Methods (Expand/Collapse)
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

/* ============================================================================
 *  PUBLIC Methods (Badges)
 */
- (void)setBadge:(id)key count:(NSInteger)badgeValue {
	SidebarFolderNode *node = [_contents objectForKey:key];
	[node setBadgeValue:badgeValue];
}

- (void)unsetBadge:(id)key {
	SidebarFolderNode *node = [_contents objectForKey:key];
	[node unsetBadgeValue];
}

/* ============================================================================
 *  PRIVATE Data Source Delegates
 */

// The child item at index of a item. 
// If item is nil, returns the appropriate child item of the root object.
- (id)outlineView:(NSOutlineView *)outlineView 
			child:(NSInteger)index
		   ofItem:(id)item
{
	if (item == nil)
		return [_roots objectAtIndex:index];
	return [item childAtIndex:index];
}

// Returns a Boolean value that indicates whether in a given item is expandable.
- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item
{
	return((item == nil) ? NO : [item nodeType] != kSidebarNodeTypeItem);
}

// Returns the number of child items encompassed by a given item.
- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item
{
	return((item == nil) ? [_roots count] : [item numberOfChildren]);
}

// Invoked by outlineView to return the data object 
// associated with the specified item.
- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
		   byItem:(id)item
{
	return [item caption];
}

/* ============================================================================
 *  PRIVATE Delegates
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
	return NO;
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
	if (action != NULL)
		[NSThread detachNewThreadSelector:action toTarget:target withObject:selectedNode];
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
	return([[fieldEditor string] length] > 0);
}

/* ============================================================================
 *  PRIVATE Delegates (Drag & Drop)
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
	
	return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView
                  validateDrop:(id<NSDraggingInfo>)info
                  proposedItem:(id)item
            proposedChildIndex:(NSInteger)index
{
	if (item == nil)
		return NSDragOperationGeneric;
	
	if (![item isDraggable] && index >= 0)
		return NSDragOperationMove;
	
	return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView*)outlineView
		 acceptDrop:(id<NSDraggingInfo>)info
			   item:(id)targetItem
		 childIndex:(NSInteger)index
{
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
		}
		
		[self reloadData];
		return YES;
	}
	
	return NO;
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event
					   inRect:(NSRect)cellFrame
					   ofView:(NSView *)controlView
{
	if ([controlView isKindOfClass:[SidebarFolderTreeView class]]) {
		SidebarFolderTreeView *sidebar = (SidebarFolderTreeView *) controlView;
		SidebarFolderNode *node = [sidebar selectedNode];
		if (![node isDraggable])
			return NSCellHitTrackableArea;
	}
	
	return NSCellHitContentArea;
}

- (void)drawRect:(NSRect)rect{
	BOOL isWindowFront = [[NSApp mainWindow] isVisible];
	if(isWindowFront){
		[self setBackgroundColor:[NSColor colorWithCalibratedRed:214.0/255.0 green:221.0/255.0 blue:229.0/255.0 alpha:1.0]];
	}else{
		[self setBackgroundColor:[NSColor colorWithCalibratedRed:232.0/255.0 green:232.0/255.0 blue:232.0/255.0 alpha:1.0]];
	}
	[super drawRect:rect];
}

@end


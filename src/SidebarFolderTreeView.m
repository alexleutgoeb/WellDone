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
 *  Constructors/Distructors
 */

- (void)dealloc {
	[_contents release];
	[_roots release];
	
	[super dealloc];
}

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
	
	// Make outline view appear with gradient selection, and behave like the Finder, iTunes, etc.
	[self setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
	
	// drag and drop support
	[self registerForDraggedTypes:[NSArray arrayWithObjects:kSidebarPBoardType, nil]];
	
	// Sub Delegates & Data Source
	[self setDataSource:self];
	[self setDelegate:self];
	
	// Insert initial root nodes
	[self initRootNodes];
	
	// Insert nodes from persistent store
	[self initFolderListFromStore];
	
	// Initialize listening to notifications by managedObjectContext
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
		   selector:@selector(reactToMOCSave:)
			   name:NSManagedObjectContextDidSaveNotification
			 object:nil];
	
	return self;
}

/*
 * Initialize the folder list from the store.
 */
- (void)initFolderListFromStore {
	NSManagedObjectContext *moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Folder" inManagedObjectContext:moc];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entityDescription];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"order" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	NSError *error;
	NSArray *folders = [moc executeFetchRequest:request error:&error];
	if (folders == nil)
	{
		// TODO: Deal with error...
	}
	[self addFolders:folders toSection:rootNodeTaskFolders];
	
}

/*
 * Initialize all root nodes which group items in the source list view.
 */
- (void) initRootNodes {
	[self addSection:rootNodeTaskFolders caption:@"FOLDERS"];
	[self reloadData];
	
	// Expand all sections' nodes
	[self expandItem:rootNodeTaskFolders];
	
	//TODO: Insert missing sections (intelligent search queries,...)
}

/* ============================================================================
 *  General Controller methods 
 */

/*
 * Save all changes done to managed objects into the persistent store.
 */
- (void) saveChangesToStore {
	NSManagedObjectContext *moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
	NSError *error;
	if (![moc save:&error]) {
		NSLog(@"Error saving changes - error:%@",error);
	}
}

/*
 * This method will be called when a save-operatoin is done to the main managedObjectContext (central application delegate's moc).
 * It reacts to some of these changes with updates to the folder tree view.
*/
- (void) reactToMOCSave:(NSNotification *)notification {
	id object;
	NSDictionary *userInfo = [notification userInfo];
	
	NSEnumerator *updatedObjects = [[userInfo objectForKey:NSUpdatedObjectsKey] objectEnumerator];
	while (object = [updatedObjects nextObject]) {
		if ([object isKindOfClass: [Folder class]]) {
			NSLog(@"NYI: Will update Folder with name: %@", [object name]);
			// TODO: handle updated objects
			// TODO: handle deleted objects (flag: delete), they are not really deleted until synchronisation
		}
	}
	
	NSEnumerator *insertedObjects = [[userInfo objectForKey:NSInsertedObjectsKey] objectEnumerator];
	while (object = [insertedObjects nextObject]) {
		if ([object isKindOfClass: [Folder class]]) {
			NSLog(@"Will insert Folder with name: %@", [object name]);
			[self addFolder:object toSection:rootNodeTaskFolders];
			[self reloadData];			
		}
	}
	
	NSEnumerator *deletedObjects = [[userInfo objectForKey:NSDeletedObjectsKey] objectEnumerator];
	while (object = [deletedObjects nextObject]) {
		if ([object isKindOfClass: [Folder class]]) {
			NSLog(@"Will delete Folder with name: %@", [object name]);
			[self removeFolder: object];
			[self reloadData];	
		}
	}
}

/*
 * Save all folders' orderings which are children of rootNodeTaskFolders (see header) to the store
 */
- (void) saveFolderOrderingToStore {
	SidebarFolderNode *parentNode = [_contents objectForKey:rootNodeTaskFolders];
	NSEnumerator *childrenEnum = [parentNode childrenEnumeration];
	id child;
	int counter = 0;
	while (child = [childrenEnum nextObject]) {
		counter++;
		if ([child isKindOfClass: [SidebarFolderNode class]]) {
			SidebarFolderNode *node = child;
			NSLog(@"Will save order for folder node: %@", [node caption]);
			Folder *currentListFolder = [node data];
			[currentListFolder setOrder: [[NSNumber alloc] initWithInt: counter]];
		}
	}
	[self saveChangesToStore];
	
}

/*
 * CURRENTLY NOT IN USE!
 * Takes a given folder. If it has an ordering value of 0, it is seen as unordered, and it is assigned a new ordering value,
 * which is maximum(all order numbers)+1
 */
- (void) fixOrderingForFolder:(Folder *)folder doSave:(BOOL)performSave {
	if ([folder order] != nil) {
		NSNumber *orderNumber = [folder order];
		if ([orderNumber intValue] == 0) {
			NSManagedObjectContext *moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
			NSEntityDescription *entityDescription = [NSEntityDescription
													  entityForName:@"Folder" inManagedObjectContext:moc];
			NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
			[request setEntity:entityDescription];
			
			NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
												initWithKey:@"order" ascending:NO];
			[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
			[request setFetchLimit:1];
			NSError *error;
			NSArray *folders = [moc executeFetchRequest:request error:&error];
			if (folders == nil)
			{
				// TODO: Deal with error...
			}
			//Get folder with the highest order count
			Folder *lastFolder = [folders lastObject];
			int newOrder;
			if (lastFolder == nil) {
				newOrder = 1;
			}
			else {
				newOrder = [[lastFolder order] intValue]+1;
			}
			
			NSNumber *newOrderNumber = [[NSNumber alloc] initWithInt:newOrder];
			[folder setOrder:newOrderNumber];
			
			if(performSave) {
				[self saveChangesToStore];
			}
		}
	}
}

/*
 * Adds a new folder to the given section. The folder entity has to provide a persistent id, or else
 * it will not be added (entity has to have been saved at least once in the moc).
 */
- (void) addFolder:(Folder *) folder toSection:(NSString *)section {
	if([[folder objectID] isTemporaryID] == YES) {
		NSLog(@"New Folder has temporary objectid!");
		return;
	}
	
	[self addChild:section 
			 key:[folder objectID]
			 caption:[folder name]
			 icon:[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)]	
			 data: folder
			 action:@selector(buttonPres:) 
			 target:self];
}

/*
 * Adds multiple folders to the given section. At the end, a reload command is sent so the list reloads all nodes.
 */
- (void) addFolders: (NSArray *) folders toSection:(NSString *)section {
	id folder;
	NSEnumerator *folderEnumerator = [folders objectEnumerator];
	while (folder = [folderEnumerator nextObject]) {
		if ([folder isKindOfClass: [Folder class]]) {
			NSLog(@"Will insert Folder with name: %@", [folder name]);
			[self addFolder:folder toSection:section];			
		}
	}
	[self reloadData];
}

/*
 * Removes the given folder from the view.
 */
- (void) removeFolder:(Folder *) folder {
	[self removeItem: [folder objectID]];
}

- (void)setDefaultAction:(SEL)action target:(id)target {
	_defaultAction = action;
	_defaultActionTarget = target;
}

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
	[node release];
}

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

	[node release];
}

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
	[node release];
}

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

- (void)removeFolder:(id)key {
	[self removeItem:key];
}

- (void)removeSection:(id)key {
	[self removeItem:key];
}

/* ============================================================================
 *  Selection of Items
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
			[self saveChangesToStore];
			
			// Set caption on folder node in view
			[node setCaption:object];
		}
		

	}
	


}

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
	//NSLog(@"proposedItem: %@", [item caption]);
	if (![item isDraggable] && index >= 0) {
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
			[self saveFolderOrderingToStore];
		}
		
		[self reloadData];
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

@end


//
//  SidebarNode.m
//  Sidebar
//
//  Created by Matteo Bertozzi on 3/8/09.
//  Copyright 2009 Matteo Bertozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SidebarBadgeCell.h>
#import <SidebarFolderTreeView.h>
#import <Task.h>
#import <Folder.h>
#import <SidebarFolderNode.h>

@interface SidebarFolderTreeView : NSOutlineView {
@private
	NSArray *dragNodesArray;
	
	id _defaultActionTarget;
	SEL _defaultAction;
	
	NSMutableDictionary *_contents;
	NSMutableArray *_roots;
	NSViewController *myController;
	NSMutableArray *allowedDragDestinations;
}

- (Folder *)selectedFolder;

- (SidebarFolderNode *) nodeForKey:(id)key;
- (void)setViewController:(NSViewController *)myController;

// Set Default Item Clicked Handler
- (void)setDefaultAction:(SEL)action target:(id)target;

// Add Root Folder Methods
- (void)addSection:(id)key
		   caption:(NSString *)folderCaption;

// Add Child Methods
- (void)addChild:(id)parentKey
			 key:(id)key
			 url:(NSString *)url;

- (void)addChild:(id)parentKey
			 key:(id)key
			 url:(NSString *)url
		  action:(SEL)aSelector
		  target:(id)target;

- (void)addChild:(id)parentKey
			 key:(id)key
		 caption:(NSString *)childCaption
			icon:(NSImage *)childIcon;

- (void)addChild:(id)parentKey
			 key:(id)key
		 caption:(NSString *)childCaption
			icon:(NSImage *)childIcon
		  action:(SEL)aSelector
		  target:(id)target;

- (void)addChild:(id)parentKey
			 key:(id)key
		 caption:(NSString *)childCaption
			icon:(NSImage *)childIcon
			data:(id)data;

- (void)addChild:(id)parentKey
			 key:(id)key
		 caption:(NSString *)childCaption
			icon:(NSImage *)childIcon
			data:(id)data
		  action:(SEL)aSelector
		  target:(id)target;

// Insert Child Methods
- (void)insertChild:(id)parentKey
				key:(id)key
			atIndex:(NSUInteger)index
				url:(NSString *)url
			 action:(SEL)aSelector
			 target:(id)target;

- (void)insertChild:(id)parentKey
				key:(id)key
			atIndex:(NSUInteger)index
			caption:(NSString *)childCaption
			   icon:(NSImage *)childIcon
			 action:(SEL)aSelector
			 target:(id)target;

- (void)insertChild:(id)parentKey
				key:(id)key
			atIndex:(NSUInteger)index
			caption:(NSString *)childCaption
			   icon:(NSImage *)childIcon
			   data:(id)data
			 action:(SEL)aSelector
			 target:(id)target;

// Remove Methods
- (void)removeItem:(id)key;
- (void)removeChild:(id)key;
- (void)removeSection:(id)key;

// Selection Methods
- (void)selectItem:(id)key;
- (void)unselectItem;

// Expand/Collapse Metods
- (void)expandAll;
- (void)expandItem:(id)key;
- (void)expandItem:(id)key expandChildren:(BOOL)expandChildren;

- (void)collapseAll;
- (void)collapseItem:(id)key;
- (void)collapseItem:(id)key expandChildren:(BOOL)collapseChildren;

// Set Badge
- (void)setBadge:(id)key count:(NSInteger)badgeValue;
- (void)unsetBadge:(id)key;

// Context menu
-(NSMenu*)defaultMenuForRow:(int)row;
-(BOOL) isRowDeletable:(int)row;
-(BOOL) mayAddFolderToRow:(int)row;
-(void) contextMenuAddFolder: (id)sender;
-(void) contextMenuDeleteFolder: (id)sender;

@end


//
//  SidebarNode.h
//  Sidebar
//
//  Created by Matteo Bertozzi on 3/8/09.
//  Copyright 2009 Matteo Bertozzi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kSidebarNodeTypeSection			0x01
#define kSidebarNodeTypeFolder			0x02
#define kSidebarNodeTypeItem			0x03

@interface SidebarFolderNode : NSObject {
	NSMutableArray *children;
	id parentKey;
	id nodeKey;
	
	NSString *caption;
	NSImage *icon;
	int nodeType;
	id data;
	
	NSInteger badgeValue;
	BOOL hasBadge;
	
	id actionTarget;
	SEL action;
}

@property (assign, readonly) id actionTarget;
@property (assign, readonly) SEL action;

@property (assign, readonly) NSInteger badgeValue;
@property (assign, readonly) BOOL hasBadge;

@property (retain) NSString *caption;
@property (retain) NSImage *icon;
@property (assign) id parentKey;
@property (assign) int nodeType;
@property (assign) id nodeKey;
@property (retain) id data;

- (void)setAction:(SEL)aSelector target:(id)target;
- (BOOL)hasAction;

- (void)setBadgeValue:(NSInteger)value;
- (void)unsetBadgeValue;

- (void)addChild:(SidebarFolderNode *)node;
- (void)insertChild:(SidebarFolderNode *)node atIndex:(NSUInteger)index;
- (void)removeChild:(SidebarFolderNode *)node;
- (NSInteger)indexOfChild:(SidebarFolderNode *)node;

- (SidebarFolderNode *)childAtIndex:(int)index;

- (NSUInteger)numberOfChildren;

- (BOOL)isDraggable;

- (NSEnumerator *)childrenEnumeration;

@end

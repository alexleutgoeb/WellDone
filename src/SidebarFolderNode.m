//
//  SidebarNode.m
//  Sidebar
//
//  Created by Matteo Bertozzi on 3/8/09.
//  Copyright 2009 Matteo Bertozzi. All rights reserved.
//

#import "SidebarFolderNode.h"

@implementation SidebarFolderNode

@synthesize actionTarget;
@synthesize action;

@synthesize badgeValue;
@synthesize hasBadge;

@synthesize parentKey;
@synthesize nodeType;
@synthesize nodeKey;
@synthesize caption;
@synthesize icon;
@synthesize data;

- (id)init {
	if ((self = [super init])) {
		children = [[NSMutableArray alloc] init];
		hasBadge = NO;
	}

	return self;
}

- (void)dealloc {
	[children release];

	[caption release];
	[icon release];
	[data release];

	[super dealloc];
}

- (void)setAction:(SEL)aSelector target:(id)target {
	actionTarget = target;
	action = aSelector;
}

- (BOOL)hasAction {
	return(action != NULL);
}

- (void)setBadgeValue:(NSInteger)value {
	hasBadge = YES;
	badgeValue = value;
}

- (void)unsetBadgeValue {
	hasBadge = NO;
}

- (void)addChild:(SidebarFolderNode *)node {
	[children addObject:node];
}

- (void)insertChild:(SidebarFolderNode *)node atIndex:(NSUInteger)index {
	[children insertObject:node atIndex:index];
}

- (void)removeChild:(SidebarFolderNode *)node {
	[children removeObject:node];
}

- (NSInteger)indexOfChild:(SidebarFolderNode *)node {
	return [children indexOfObject:node];
}

- (SidebarFolderNode *)childItemAtIndex:(int)index {
	return([children objectAtIndex:index]);
}

- (NSUInteger)numberOfChildren {
	return([children count]);
}

- (BOOL)isDraggable {
	return(nodeType != kSidebarNodeTypeSection);
}

- (NSEnumerator *)childrenEnumeration {
	return [children objectEnumerator];
}

@end

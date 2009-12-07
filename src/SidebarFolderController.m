//
//  SidebarFolderController.m
//  WellDone
//
//  Created by Manuel Maly on 06.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SidebarFolderController.h"


@implementation SidebarFolderController

- (id) init
{
	self = [super initWithNibName:@"FolderSourceListView" bundle:nil];
	if (self != nil)
	{		
	}
	return self;
}

- (void) awakeFromNib {

		[sidebar setDefaultAction:@selector(buttonDefaultHandler:) target:self];
		
	/*
		[sidebar addSection:@"1" caption:@"DEVICES"];
		[sidebar addSection:@"2" caption:@"PLACES"];
		
		[sidebar addChild:@"1" key:@"1.1" caption:@"Machintosh HD" icon:[NSImage imageNamed:NSImageNameComputer] action:@selector(buttonPres:) target:self];
		[sidebar addChild:@"1" key:@"1.2" caption:@"Network" icon:[NSImage imageNamed:NSImageNameNetwork] action:@selector(buttonPres:) target:self];
		
		[sidebar addChild:@"2" key:@"2.1" url:NSHomeDirectory() action:@selector(buttonPres:) target:self];
		[sidebar addChild:@"2" key:@"2.2" url:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"] action:@selector(buttonPres:) target:self];
		[sidebar addChild:@"2" key:@"2.3" url:[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"] action:@selector(buttonPres:) target:self];
		[sidebar addChild:@"2" key:@"2.4" url:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] action:@selector(buttonPres:) target:self];
		[sidebar addChild:@"2" key:@"2.5" url:@"/Applications" action:@selector(buttonPres:) target:self];
		[sidebar addChild:@"2" key:@"2.6" url:NSHomeDirectory() action:@selector(buttonPres:) target:self];
		[sidebar addChild:@"2" key:@"2.7" url:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"] action:@selector(buttonPres:) target:self];
		[sidebar addChild:@"2" key:@"2.8" url:[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"] action:@selector(buttonPres:) target:self];
		[sidebar addChild:@"2" key:@"2.9" url:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] action:@selector(buttonPres:) target:self];
		[sidebar addChild:@"2" key:@"2.10" url:@"/Applications" action:@selector(buttonPres:) target:self];
		
		[sidebar addSection:@"3" caption:@"OTHER"];
		[sidebar addChild:@"3" key:@"3.1" caption:@"Bonjour" icon:[NSImage imageNamed:NSImageNameBonjour]];
		[sidebar addChild:@"3" key:@"3.2" caption:@"Mobile Me" icon:[NSImage imageNamed:NSImageNameDotMac]];
		[sidebar addChild:@"3" key:@"3.3" caption:@"Users" icon:[NSImage imageNamed:NSImageNameUserGroup]];
		[sidebar addChild:@"3" key:@"3.4" caption:@"Everyone" icon:[NSImage imageNamed:NSImageNameEveryone]];
		[sidebar addChild:@"3" key:@"3.5" caption:@"Smart" icon:[NSImage imageNamed:NSImageNameSmartBadgeTemplate]];
		[sidebar addChild:@"3.5" key:@"3.5.1" caption:@"SmartX" icon:[NSImage imageNamed:NSImageNameSmartBadgeTemplate]];
	
		[sidebar setBadge:@"1.2" count:5];
		[sidebar setBadge:@"2.3" count:3];
		[sidebar setBadge:@"3.1" count:4];
		
		[sidebar reloadData];
		
		[sidebar expandItem:@"3"];
		*/
		
}

- (IBAction)addChild: (id)sender{
	[sidebar addChild:@"3" key:@"3.1" caption:@"Bonjour" icon:[NSImage imageNamed:NSImageNameBonjour]];
	[sidebar reloadData];
}

@end

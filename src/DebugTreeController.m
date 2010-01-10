//
//  DebugTreeController.m
//  WellDone
//
//  Created by Manuel Maly on 10.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DebugTreeController.h"


@implementation DebugTreeController

- (void) fetch:(id)sender {
	[super fetch:sender];
	NSLog(@"Performed Fetch in Tree Controller - content: %@", [self content]);

}

@end

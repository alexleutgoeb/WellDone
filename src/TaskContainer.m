//
//  TaskContainer.m
//  WellDone
//
//  Created by Alex Leutgöb on 14.01.10.
//  Copyright 2010 alexleutgoeb.com. All rights reserved.
//

#import "TaskContainer.h"


@implementation TaskContainer


- (void)dealloc {
	[remoteTask release];
	[gtdTask release];
}

@end

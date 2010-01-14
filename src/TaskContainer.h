//
//  TaskContainer.h
//  WellDone
//
//  Created by Alex Leutgöb on 14.01.10.
//  Copyright 2010 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GtdTask.h"
#import "RemoteTask.h"

@interface TaskContainer : NSObject {
@private
	GtdTask *gtdTask;
	RemoteTask *remoteTask;
}

@property (nonatomic, retain) GtdTask *gtdTask;
@property (nonatomic, retain) RemoteTask *remoteTask;

@end

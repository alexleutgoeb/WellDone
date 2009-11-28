//
//  SyncManager.h
//  WellDone
//
//  Created by Alex Leutgöb on 28.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SyncManager : NSObject {
@private
	id delegate;
	NSDictionary *syncServices;
}

@property (nonatomic, assign) id delegate;

-(id)initWithDelegate:(id)aDelegate;
- (void)registerSyncService:(id)syncService;

@end

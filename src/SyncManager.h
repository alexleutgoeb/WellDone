//
//  SyncManager.h
//  WellDone
//
//  Created by Alex Leutgöb on 28.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GtdApi.h"


/**
 SyncManager class
 The SyncManager class handles synchronisation with different sync services which 
 conform to the formal GtdApi protocol. The manager detects syncing conflicts which 
 will be reported to the designated delegate object.
 */
@interface SyncManager : NSObject {
@private
	id delegate;
	NSDictionary *syncServices;
}

@property (nonatomic, assign) id delegate;

/**
 Custom initializer with delegate object
 Initializes a new SyncManager object with the given delegate. The delegate must 
 implement the SyncManagerDelegate protocol and is used to inform about sync 
 conflicts.
 @param aDelegate the delegate to be set
 @return the initialized object, or nil if an error occured
 */
-(id)initWithDelegate:(id)aDelegate;


/**
 Adds a sync service to the manager
 The method adds a sync servce, which must confrom to the GtdApi-protocol, to 
 the sync manager. The new service will be used for the next triggered syncing.
 @param aSyncService the sync service which should be added
 */
- (void)registerSyncService:(id<GtdApi>)aSyncService;

@end

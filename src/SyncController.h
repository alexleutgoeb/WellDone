//
//  SyncController.h
//  WellDone
//
//  Created by Alex Leutgöb on 12.12.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SyncManager;

@interface SyncController : NSObject {
@private
	// List of available sync services
	NSMutableDictionary *syncServices;
	// Instance of the syncmanager
	SyncManager *syncManager;
	
	// queue for sync operations
	NSOperationQueue *syncQueue;
}

@property(nonatomic, readonly) NSMutableDictionary *syncServices;

- (BOOL)enableSyncService:(NSString *)anIdentifier WithUser:(NSString *)aUser andPwd:(NSString *)aPwd;
- (BOOL)disableSyncService:(NSString *)anIdentifier;

- (void)sync;

@end

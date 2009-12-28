//
//  SyncController.h
//  WellDone
//
//  Created by Alex Leutgöb on 12.12.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SyncController, SyncManager;


// Protocol for the parser to communicate with its delegate.
@protocol SyncControllerDelegate <NSObject>

@optional
- (void)syncControllerDidSyncWithSuccess:(SyncController *)sc;
- (void)syncControllerDidSyncWithConflicts:(SyncController *)sc;
- (void)syncController:(SyncController *)sc didSyncWithError:(NSError *)error;

@end


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

- (BOOL)enableSyncService:(NSString *)anIdentifier withUser:(NSString *)aUser andPwd:(NSString *)aPwd;
- (BOOL)disableSyncService:(NSString *)anIdentifier;

- (void)sync;

@end

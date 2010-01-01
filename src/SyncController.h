//
//  SyncController.h
//  WellDone
//
//  Created by Alex Leutgöb on 12.12.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SyncController, SyncManager;


/**
 SyncControllerDelegate protocol provides callback methods for communicating with 
 a delegate while syncing.
 */
@protocol SyncControllerDelegate <NSObject>

@optional

/**
 Callback method for notifying the delegate about a successful sync.
 @param sc the sync controller instance
 */
- (void)syncControllerDidSyncWithSuccess:(SyncController *)sc;

/**
 Callback method for notifying the delegate about conflicts in sync.
 @param sc the sync controller instance
 */
- (void)syncControllerDidSyncWithConflicts:(SyncController *)sc;

/**
 Callback method for notifying the delegate about an error while syncing.
 @param sc the sync controller instance
 @param error the emerged error during syncing
 */
- (void)syncController:(SyncController *)sc didSyncWithError:(NSError *)error;

@end


/**
 SyncController class
 The class is the main class for enabling services and trigger a sync.
 */
@interface SyncController : NSObject {
@private
	// List of available sync services
	NSMutableDictionary *syncServices;
	// Instance of the syncmanager
	SyncManager *syncManager;
	
	// queue for sync operations
	NSOperationQueue *syncQueue;
	
	// counter for active services
	NSInteger activeServicesCount;
}

/**
 Getter for a list of all available sync services.
 */
@property(nonatomic, readonly) NSMutableDictionary *syncServices;

/**
 Returns the number of available sync services.
 */
@property(nonatomic, readonly) NSInteger servicesCount;

/**
 Returns the number of active sync services.
 */
@property(nonatomic, readonly) NSInteger activeServicesCount;

/**
 Enables a syncService in the sync controller.
 @param anIdentifier specific syncService identifer to enable
 @param aUser username for login
 @param aPwd password for login
 @param anError error object if enabling the service failed
 */
- (BOOL)enableSyncService:(NSString *)anIdentifier withUser:(NSString *)aUser pwd:(NSString *)aPwd error:(NSError **)anError;

/**
 Disables a specific syncService in the sync controller.
 @param anIdentifier the specific syncService identifiert to disable
 */
- (BOOL)disableSyncService:(NSString *)anIdentifier;

/**
 Starts the sync in background. Notifications about success and failures will be 
 sent through the sync controller delegate.
 */
- (void)sync;

@end

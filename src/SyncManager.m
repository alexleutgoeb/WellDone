//
//  SyncManager.m
//  WellDone
//
//  Created by Alex Leutgöb on 28.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "SyncManager.h"

@interface SyncManager()

@property (nonatomic, retain) NSMutableDictionary *syncServices;

@end



@implementation SyncManager

@synthesize delegate;
@synthesize syncServices;


#pragma mark -
#pragma mark general methods

-(id)initWithDelegate:(id)aDelegate {
	if (self = [self init]) {
		self.delegate = aDelegate;
		self.syncServices = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc {
	[syncServices release];
	self.delegate = nil;
	[super dealloc];
}



#pragma mark -
#pragma mark sync manager methods

- (void)registerSyncService:(id<GtdApi>)aSyncService {
	
	if ([(NSObject *)aSyncService conformsToProtocol:@protocol(GtdApi)] != NO) {
		// syncService is a valid GtdApi implementation
		[syncServices setObject:aSyncService forKey:[aSyncService identifier]];
	}
	else {
		// syncService does not conform to protocol, not added
	}
}

- (void)unregisterSyncService:(id<GtdApi>)aSyncService {
	if ([syncServices objectForKey:aSyncService.identifier] != nil) {
		[syncServices removeObjectForKey:aSyncService.identifier];
	}
}

- (void)unregisterSyncServiceWithIdentifier:(NSString *)anIdentifier {
	if ([syncServices objectForKey:anIdentifier] != nil) {
		[syncServices removeObjectForKey:anIdentifier];
	}
}

@end

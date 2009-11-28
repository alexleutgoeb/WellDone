//
//  SyncManager.m
//  WellDone
//
//  Created by Alex Leutgöb on 28.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "SyncManager.h"
#import "GtdApi.h"

@interface SyncManager()

@property (nonatomic, retain) NSDictionary *syncServices;

@end



@implementation SyncManager

@synthesize delegate;
@synthesize syncServices;


#pragma mark -
#pragma mark general methods

-(id)initWithDelegate:(id)aDelegate {
	if (self = [self init]) {
		self.delegate = aDelegate;
		self.syncServices = [[NSDictionary alloc] init];
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

- (void)registerSyncService:(id)syncService {
	
}

@end

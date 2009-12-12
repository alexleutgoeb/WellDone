//
//  SyncService.h
//  WellDone
//
//  Created by Alex Leutgöb on 12.12.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GtdApi.h"

/**
 Wrapper class for GtdApi implementations
 The class needs the class of the  implementation for creating a dynamic 
 instance.
 */
@interface SyncService : NSObject {
@private
	Class ApiClass;
	id<GtdApi> api;
	NSString *user;
	NSString *pwd;
}

@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *pwd;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) BOOL isEnabled;

- (id)initWithApiClass:(Class)anApiClass;
- (BOOL)activateService:(NSError **)error;

@end

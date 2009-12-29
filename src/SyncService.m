//
//  SyncService.m
//  WellDone
//
//  Created by Alex Leutgöb on 12.12.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import "SyncService.h"


@implementation SyncService

@synthesize user, pwd, api;

- (id)initWithApiClass:(Class)anApiClass {
	if (self = [self init]) {
		ApiClass = anApiClass;
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	;
	return self;
}

- (void)dealloc {
	ApiClass = NULL;
	api = nil;
	[pwd release];
	[user release];
	[super dealloc];
}

- (NSString *)description {
	return self.identifier;
}

- (NSString *)identifier {
	return [ApiClass identifier];
}

- (BOOL)isEnabled {
	return api == nil ? NO : YES;
}

- (BOOL)activate:(NSError **)error {
	DLog(@"Trying to activate sync service...");
	
	NSError *initError = nil;
	
	if (self.user != nil && self.pwd != nil) {

		api = [[ApiClass alloc] initWithUsername:user password:pwd error:&initError];
		
		if (api == nil || initError != nil) {
			DLog(@"Error while activating sync service: %@", *error);
			
			// Check error and create custom error object
			if ([initError code] == GtdApiMissingCredentialsError) {
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:@"ich NSLocalizedDescriptionKey" forKey:NSLocalizedDescriptionKey];
				[errorDetail setValue:@"ich NSLocalizedFailureReasonErrorKey" forKey:NSLocalizedFailureReasonErrorKey];
				[errorDetail setValue:@"ich NSLocalizedRecoverySuggestionErrorKey" forKey:NSLocalizedRecoverySuggestionErrorKey];
				*error = [NSError errorWithDomain:[initError domain] code:[initError code] userInfo:errorDetail];
			}
			else if ([initError code] == GtdApiWrongCredentialsError) {
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:@"Failed to do something wicked" forKey:NSLocalizedDescriptionKey];
				*error = [NSError errorWithDomain:@"myDomain" code:100 userInfo:errorDetail];
			}
			else {
				
			}
			
			return NO;
		}
		else {
			return YES;
		}
	}
	else {
		DLog(@"User/pwd not set.");
		return NO;
	}
}

- (void)deactivate {
	[api release];
	api = nil;
}

@end

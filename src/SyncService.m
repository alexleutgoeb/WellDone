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
			DLog(@"Error while activating sync service: %@", initError);
			
			// Check error and create custom error object
			if ([initError code] == GtdApiMissingCredentialsError) {
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:@"Missing credentials" forKey:NSLocalizedDescriptionKey];
				[errorDetail setValue:@"Please provide your credentials for the sync service." forKey:NSLocalizedRecoverySuggestionErrorKey];
				*error = [NSError errorWithDomain:[initError domain] code:[initError code] userInfo:errorDetail];
			}
			else if ([initError code] == GtdApiWrongCredentialsError) {
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:@"Wrong credentials" forKey:NSLocalizedDescriptionKey];
				[errorDetail setValue:@"Your credentials were declined by the service. Please provide valid credentials." forKey:NSLocalizedRecoverySuggestionErrorKey];
				*error = [NSError errorWithDomain:[initError domain] code:[initError code] userInfo:errorDetail];
			}
			else {
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:@"Unkown Error" forKey:NSLocalizedDescriptionKey];
				[errorDetail setValue:@"An unknown error happened, shit." forKey:NSLocalizedRecoverySuggestionErrorKey];
				*error = [NSError errorWithDomain:[initError domain] code:[initError code] userInfo:errorDetail];
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

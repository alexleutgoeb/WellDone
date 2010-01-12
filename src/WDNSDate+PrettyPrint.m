//
//  WDNSDate+PrettyPrint.m
//  WellDone
//
//  Created by Alex Leutgöb on 12.01.10.
//  Copyright 2010 alexleutgoeb.com. All rights reserved.
//

#import "WDNSDate+PrettyPrint.h"


@implementation NSDate (WDPrettyPrint)

static NSDateFormatter *dateFormatter = nil;

- (NSString *)prettyDateWithReference:(NSDate *)reference {
	float diff = [reference timeIntervalSinceDate:self];
	float distance = floor(diff);
	
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
	}    
	
	if (distance < 60 * 60 * 24) {
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		return [NSString stringWithFormat:@"Today, %@", [dateFormatter stringFromDate:self]];
	}
	else if (distance < 60 * 60 * 24 * 2) {
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		return [NSString stringWithFormat:@"Yesterday, %@", [dateFormatter stringFromDate:self]];
	}
	else {
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		return [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:self]];
	}
}

- (NSString *)prettyDate {
	return [self prettyDateWithReference:[NSDate date]];
}

@end

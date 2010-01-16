//
//  WDNSSet+subset.m
//  WellDone
//
//  Created by Alex Leutgöb on 15.01.10.
//  Copyright 2010 alexleutgoeb.com. All rights reserved.
//

#import "WDNSSet+subset.h"


@implementation NSSet (WDSubSet)

- (NSSet *)subsetWithKey:(NSString *)aKey value:(id)aValue {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K=%@", aKey,aValue];
	NSSet *subset = [self filteredSetUsingPredicate:predicate];
	return subset;
}

@end

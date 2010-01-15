//
//  WDNSSet+subset.h
//  WellDone
//
//  Created by Alex Leutgöb on 15.01.10.
//  Copyright 2010 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSSet (WDSubSet)

- (NSSet *)subsetWithKey:(NSString *)aKey value:(id)aValue;

@end

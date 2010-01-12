//
//  WDNSDate+PrettyPrint.h
//  WellDone
//
//  Created by Alex Leutgöb on 12.01.10.
//  Copyright 2010 alexleutgoeb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSDate (WDPrettyPrint)

- (NSString *)prettyDateWithReference:(NSDate *)reference;
- (NSString *)prettyDate;

@end

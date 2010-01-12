//
//  CLDateToWeekdayValueTransformer.m
//
//  Created by Alex Clarke on 24/12/04.
//	2005 CocoaLab. All rights reserved.
//

#import "CLDateToWeekdayValueTransformer.h"


@implementation CLDateToWeekdayValueTransformer

+ (Class)transformedValueClass;
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation;
{
    return NO;   
}

- (id)transformedValue:(id)value;
{
	NSCalendarDate * aDate = [NSCalendarDate dateWithString:[value description]];
	NSString * weekdayOutputValue;
    
    if (value == nil) return nil;

    weekdayOutputValue = [aDate descriptionWithCalendarFormat:@"%A"];

    return weekdayOutputValue;
}

@end

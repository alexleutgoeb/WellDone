//
//  CLNotFaultBooleanValueTranformer.m
//
//  Created by Alex Clarke on 7/02/05.
//  2005 CocoaLab. All rights reserved.
//

#import "CLNotFaultBoolValueTransformer.h"


@implementation CLNotFaultBoolValueTransformer

+ (Class)transformedValueClass;
{
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation;
{
    return NO;   
}

- (id)transformedValue:(id)value;
{
	NSNumber * periodOutputValue;
	if (value == nil) 
	{
		return [NSNumber numberWithInt:0];
	}
	if ([value count]== 0) 
	{
		periodOutputValue = [NSNumber numberWithInt:0]; 
	} 
	else 
	{
		periodOutputValue = [NSNumber numberWithInt:1]; 
	}
	return periodOutputValue;
}

@end

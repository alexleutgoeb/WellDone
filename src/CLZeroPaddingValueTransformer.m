//
//  CLZeroPaddingValueTransformer.m
//
//  Created by Alex Clarke on 31/12/04.
//	2005 CocoaLab. All rights reserved.
//

#import "CLZeroPaddingValueTransformer.h"


@implementation CLZeroPaddingValueTransformer

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
	int valueInt = [value intValue];
	NSString * zeroPaddedOutputData;
    
    if (value == nil) return nil;
	
    zeroPaddedOutputData = [[[NSString alloc] initWithFormat:@"%02d", valueInt] autorelease];
    return zeroPaddedOutputData;
	
}

@end

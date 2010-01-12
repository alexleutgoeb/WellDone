//
//  CLPointsToUnitsTransformer.m
//
//  Created by Alex Clarke on 6/04/05.
//  2005 CocoaLab. All rights reserved.
//

//	This Value transformer uses an instance variable to track the currently
//	selected units.


#import "CLPointsToUnitsTransformer.h"


@implementation CLPointsToUnitsTransformer

+ (Class)transformedValueClass
{
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}


- (id)transformedValue:(id)aNumber
{
	
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSString * theUnits = [defaults valueForKey:@"defaultSelectedUnits"];
	[self setUnits:theUnits];	
	
    float value = [aNumber floatValue];

	if ([[self units] isEqualToString:@"Millimetres"])
	{
		NSNumber * result = [NSNumber numberWithFloat: (value / 2.835)];
		//NSLog(@"%f points to %@ %@",value, result, theUnits);
		return result;
	}
	else if  ([[self units] isEqualToString:@"Centimetres"])
	{
		NSNumber * result = [NSNumber numberWithFloat: (value / 28.35)];
		//NSLog(@"%f points to %@ %@",value, result, theUnits);
		return result;
	}
	else if  ([[self units] isEqualToString:@"Inches"])
	{
		NSNumber * result = [NSNumber numberWithFloat: (value / 72)];
		//NSLog(@"%f points to %@ %@",value, result, theUnits);
		return result;
	}

	return [NSNumber numberWithFloat: value];		
}

- (id)reverseTransformedValue:(id)aNumber
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
	NSString * theUnits = [defaults valueForKey:@"defaultSelectedUnits"];
	[self setUnits:theUnits];
	
    float value = [aNumber floatValue];
	
	if ([[self units]isEqualToString:@"Millimetres"])
	{
		return [NSNumber numberWithFloat: (value * 2.835)];
	}
	else if  ([[self units] isEqualToString:@"Centimetres"])
	{
		return [NSNumber numberWithFloat: (value * 28.35)];		
	}
	else if  ([[self units]isEqualToString:@"Inches"])
	{
		return [NSNumber numberWithFloat: (value * 72)];		
	}
	
	return [NSNumber numberWithFloat: value];		
}

//----Accessors----//

- (NSString *)units
{
    return units; 
}
- (void)setUnits:(NSString *)theUnits
{
    if (units != theUnits) {
        [units release];
        units = [theUnits retain];
    }
}


- (void)dealloc
{
    [self setUnits:nil];
    [units release];
    [super dealloc];
}


@end

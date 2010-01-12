//
//  CLPointsToUnitsTransformer.h
//
//  Created by Alex Clarke on 6/04/05.
//  2005 CocoaLab. All rights reserved.
//

//	Converts Points to the Units in the instance variable. Reversible.

#import <Cocoa/Cocoa.h>


@interface CLPointsToUnitsTransformer : NSValueTransformer 
{
	NSString * units;
}

+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;

- (NSString *)units;
- (void)setUnits:(NSString *)anUnits;

@end

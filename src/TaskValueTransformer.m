//
//  OMSetToArrayValueTransformerOBJC.m
//  WellDone
//
//  Created by Christian Hattinger on 10.12.09.
//  Copyright 2009 TU Wien. All rights reserved.
//

#import "TaskValueTransformer.h"
#import "Tag.h"


@implementation TaskValueTransformer

+ (Class) transformedValueClass
{
	return [NSMutableArray class];
}

+ (BOOL) allowsReverseTransformation
{
	return YES;
}

- (id) transformedValue:(id) value
{
	NSLog(@"transformedValue: FORWARD");
	
	if (value == nil) return nil;
	
	// check if value has the right class type
	if ([[value className] compare: @"_NSFaultingMutableSet"]) {
		[NSException raise: NSInternalInconsistencyException
					format: @"Value (%@) has wrong type.",
					[value className]];
	}
	
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	
	for (id tag in value) {
		//NSLog(@"Tag: %@",tag);
		[returnArray addObject: [tag text]];
	}
	
	if ([returnArray count] == 0) return nil;
	return returnArray;
}

- (id) reverseTransformedValue:(id) value
{
	// should return Tag-OBJECTs?????
	
	NSLog(@"REVERSE");
	//return value;
	return [NSMutableSet setWithArray:value];
	//return nil;
}

@end
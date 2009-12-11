//
//  OMSetToArrayValueTransformerOBJC.m
//  WellDone
//
//  Created by Christian Hattinger on 10.12.09.
//  Copyright 2009 TU Wien. All rights reserved.
//

#import "TaskValueTransformer.h"


@implementation TaskValueTransformer

+ (Class) transformedValueClass
{
	return [NSMutableArray class];
}

+ (BOOL) allowsReverseTransformation
{
	return NO;
}

- (id) transformedValue:(id) value
{
	NSLog(@"transformedValue: FORWARD");
	
	NSMutableArray *returnArray=[[NSMutableArray alloc]init];
	NSEnumerator *e = [value objectEnumerator];
	id collectionMemberObject;
	
	while ( (collectionMemberObject = [e nextObject]) ) {
		[returnArray addObject:(NSString *) [collectionMemberObject text]];
	}
	
	return returnArray;
}

- (id) reverseTransformedValue:(id) value
{
	NSLog(@"REVERSE");
	return [NSSet setWithArray:value];
	//return nil;
}

@end
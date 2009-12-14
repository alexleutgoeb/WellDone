//
//  OMSetToArrayValueTransformerOBJC.h
//  WellDone
//
//  Created by Christian Hattinger on 10.12.09.
//  Copyright 2009 TU Wien. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TaskValueTransformer : NSValueTransformer {

}

+ (Class) transformedValueClass;
+ (BOOL) allowsReverseTransformation;
- (id) transformedValue:(id) value;
- (id) reverseTransformedValue:(id) value;
@end

//
//  CLZeroPaddingValueTransformer.h
//
//  Created by Alex Clarke on 31/12/04.
//	2005 CocoaLab. All rights reserved.
//

//	Prefixes zeros to an NSNumber.

#import <Cocoa/Cocoa.h>


@interface CLZeroPaddingValueTransformer : NSValueTransformer {

}

+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;

@end

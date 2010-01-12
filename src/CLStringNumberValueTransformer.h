//
//  CLStringNumberValueTransformer.h
//
//  Created by Alex Clarke on 15/01/05.
//	2005 CocoaLab. All rights reserved.
//

//Converts NSStrings to NSNumbers. Reversible.

#import <Cocoa/Cocoa.h>


@interface CLStringNumberValueTransformer : NSValueTransformer {
	
}

+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;

@end

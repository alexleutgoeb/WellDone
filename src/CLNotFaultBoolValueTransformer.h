//
//  CLNotFaultBooleanValueTranformer.h
//
//  Created by Alex Clarke on 7/02/05.
//	2005 CocoaLab. All rights reserved.
//

//	Useful for CoreData, which returns a fault for an empty relationship.
//	Binding "enabled" using this Transformer disables a control 
//	when there is a fault.


#import <Cocoa/Cocoa.h>


@interface CLNotFaultBoolValueTransformer : NSValueTransformer {
	
}

+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;


@end

//
//  CLIsFaultBoolValueTransformer.h
//
//  Created by Alex Clarke on 6/02/05.
//  2005 CocoaLab. All rights reserved.
//

//	Useful for CoreData, which returns a fault for an empty relationship.
//	Binding visible using this Transformer hides a control when there is a fault.


#import <Cocoa/Cocoa.h>


@interface CLIsFaultBoolValueTransformer : NSValueTransformer {
	
}

+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;


@end

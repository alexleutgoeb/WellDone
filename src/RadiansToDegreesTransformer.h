
#import <Cocoa/Cocoa.h>


@interface RadiansToDegreesTransformer : NSValueTransformer {

}

+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;

@end

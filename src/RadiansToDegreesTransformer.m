
#import "RadiansToDegreesTransformer.h"


@implementation RadiansToDegreesTransformer

+ (Class)transformedValueClass
{
    return [NSNumber self];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)aNumber
{
    double radians = [aNumber doubleValue];
    return [NSNumber numberWithDouble: (radians / (3.1415927/180.0))];
}

- (id)reverseTransformedValue:(id)aNumber
{
    double degrees = [aNumber doubleValue];
    return [NSNumber numberWithDouble: (degrees * (3.1415927/180.0))];
}

@end

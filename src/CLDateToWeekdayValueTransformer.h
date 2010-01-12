//
//  DateToWeekdayValueTransformer.h
//  Periodical Engine
//
//  Created by Alex Clarke on 24/12/04.
//  2005 CocoaLab. All rights reserved.
//

//	Returns the day of the week for a given date.

#import <Cocoa/Cocoa.h>


@interface CLDateToWeekdayValueTransformer : NSValueTransformer {

}

+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;

@end

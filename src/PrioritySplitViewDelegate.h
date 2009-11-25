//
//  PrioritySplitViewDelegate.h
//  WellDone
//
//  Created by Manuel Maly on 25.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PrioritySplitViewDelegate : NSObject
{
    NSMutableDictionary *lengthsByViewIndex;
    NSMutableDictionary *viewIndicesByPriority;
}

- (void)setMinimumLength:(CGFloat)minLength
		  forViewAtIndex:(NSInteger)viewIndex;
- (void)setPriority:(NSInteger)priorityIndex
	 forViewAtIndex:(NSInteger)viewIndex;

@end

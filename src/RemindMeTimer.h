//
//  RemindMeTimer.h
//  WellDone
//
//  Created by Dominik Hofer on 14/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RemindMeTimer : NSObject {
	NSManagedObjectContext *moc;
	NSTimer *timer;
}
- (void)startTimer;
- (void)stopTimer;
- (void)remindUser:(NSTimer*)timer;
@property(nonatomic,retain) NSTimer *timer;
@end

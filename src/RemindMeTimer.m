//
//  RemindMeTimer.m
//  WellDone
//
//  Created by Dominik Hofer on 14/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RemindMeTimer.h"
#import "Task.h"


@implementation RemindMeTimer
@synthesize timer;

- (void)startTimer {
	timer = [NSTimer scheduledTimerWithTimeInterval: 30.0 target:self selector:@selector(remindUser:) userInfo:nil repeats: YES];
}
- (void)stopTimer {
	[timer invalidate];
}

- (void)remindUser:(NSTimer*)timer {	
	if (moc == nil) {
		moc = [[NSApp delegate] managedObjectContext];
	}
	@synchronized(moc) {
		// moc speichern
		
		NSError *error = nil;
		if (![moc save:&error]) {
			DLog(@"Error saving moc for timer, don't know what to do.");
		} else {
			//DLog(@"Updated tags in Task.");
		}
	
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:moc];
		NSPredicate *predicate = [NSPredicate predicateWithFormat: @"reminder != 0 AND (startDate - reminder * 60 <= %@ AND deletedByApp == NO)", [NSDate date]];
		[fetchRequest setEntity:entity];	
		[fetchRequest setPredicate:predicate];	
		NSArray *result = [moc executeFetchRequest:fetchRequest error:&error];
		if ([result count] == 0) return;
		else {
			NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
			[dateFormat setDateFormat:@"DD/MM/YYYY HH:MM"];
			
			NSLog(@"reminding following tasks:");
			NSString *msg = @"Upcoming event(s): ";
			for (Task *task in result) {
				NSLog(@"%@",[task title]);
				[task setReminder:0];
				msg = [NSString stringWithFormat: @"%@\n%@ - %@",msg,[task title] ,[dateFormat stringFromDate:[task startDate]]];
			}
			
			if (![moc save:&error]) {
				DLog(@"Error saving moc for timer, don't know what to do.");
			} else {
				//DLog(@"Updated tags in Task.");
			}
			
			NSAlert *alert = [[NSAlert alloc] init];
			[alert setMessageText:msg];	
			[alert runModal];
		}
	}
}


@end

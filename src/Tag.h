//
//  Tag.h
//  WellDone
//
//  Created by Alex Leutgöb on 30.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Task;

@interface Tag :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * deletedByApp;
@property (nonatomic, retain) NSString * text;

@end

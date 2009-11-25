//
//  Tag.h
//  WellDone
//
//  Created by Manuel Maly on 25.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Tag :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSManagedObject * task;

@end




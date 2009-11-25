//
//  Note.h
//  WellDone
//
//  Created by Manuel Maly on 25.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Folder;

@interface Note :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * private;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * date_created;
@property (nonatomic, retain) NSDate * date_modified;
@property (nonatomic, retain) Folder * folder;

@end




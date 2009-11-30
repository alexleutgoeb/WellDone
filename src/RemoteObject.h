//
//  RemoteObject.h
//  WellDone
//
//  Created by Alex Leutgöb on 30.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface RemoteObject :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * serviceIdentifier;
@property (nonatomic, retain) NSNumber * remoteUid;
@property (nonatomic, retain) NSDate * lastsyncDate;

@end




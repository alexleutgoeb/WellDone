//
//  Note.h
//  WellDone
//
//  Created by Alex Leutgöb on 30.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Folder;
@class RemoteNote;

@interface Note :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSNumber * private;
@property (nonatomic, retain) Folder * folder;
@property (nonatomic, retain) NSSet* remoteNotes;

@end


@interface Note (CoreDataGeneratedAccessors)
- (void)addRemoteNotesObject:(RemoteNote *)value;
- (void)removeRemoteNotesObject:(RemoteNote *)value;
- (void)addRemoteNotes:(NSSet *)value;
- (void)removeRemoteNotes:(NSSet *)value;

@end


//
//  Folder.h
//  WellDone
//
//  Created by Alex Leutgöb on 30.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Note;
@class RemoteFolder;
@class Task;

@interface Folder :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSNumber * private;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* tasks;
@property (nonatomic, retain) NSSet* notebooks;
@property (nonatomic, retain) NSSet* remoteFolders;

@end


@interface Folder (CoreDataGeneratedAccessors)
- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet *)value;
- (void)removeTasks:(NSSet *)value;

- (void)addNotebooksObject:(Note *)value;
- (void)removeNotebooksObject:(Note *)value;
- (void)addNotebooks:(NSSet *)value;
- (void)removeNotebooks:(NSSet *)value;

- (void)addRemoteFoldersObject:(RemoteFolder *)value;
- (void)removeRemoteFoldersObject:(RemoteFolder *)value;
- (void)addRemoteFolders:(NSSet *)value;
- (void)removeRemoteFolders:(NSSet *)value;

@end


//
//  RemoteFolder.h
//  WellDone
//
//  Created by Alex Leutgöb on 30.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "RemoteObject.h"

@class Folder;

@interface RemoteFolder :  RemoteObject  
{
}

@property (nonatomic, retain) Folder *localFolder;

@end




//
//  RemoteNote.h
//  WellDone
//
//  Created by Alex Leutgöb on 30.11.09.
//  Copyright 2009 alexleutgoeb.com. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "RemoteObject.h"

@class Note;

@interface RemoteNote :  RemoteObject  
{
}

@property (nonatomic, retain) Note * localNote;

@end




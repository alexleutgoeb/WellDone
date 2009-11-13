//
//  WellDone_AppDelegate.h
//  WellDone
//
//  Created by Alex Leutgöb on 27.10.09.
//  Copyright alexleutgoeb.com 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindowController.h";

@interface WellDone_AppDelegate : NSObject 
{
    NSWindow *window;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	MainWindowController *mainWindowController;
}

@property (nonatomic, retain) IBOutlet NSWindow *window;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:sender;

@end

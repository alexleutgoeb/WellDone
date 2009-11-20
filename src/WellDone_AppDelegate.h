//
//  WellDone_AppDelegate.h
//  WellDone
//
//  Created by Alex Leutgöb on 27.10.09.
//  Copyright alexleutgoeb.com 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SidebarTaskController.h>
#import <SimpleListController.h>
#import <SidebarFolderController.h>
#import <TestDataGeneratorController.h>

@interface WellDone_AppDelegate : NSObject 
{
    IBOutlet NSWindow *window;
	IBOutlet NSView* sidebarTaskPlaceholderView;
	IBOutlet NSView* simpleListPlaceholderView;
	IBOutlet NSView* sidebarFolderPlaceholderView;
    
	SidebarTaskController* sidebarTaskController;
	SimpleListController* simpleListController;
	SidebarFolderController* sidebarFolderController;
	
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:sender;
- (void)showTestdatagenerator:(id)sender;

@end

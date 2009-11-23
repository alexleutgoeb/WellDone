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
#import <GTDListController.h>
#import <SidebarFolderController.h>
#import <TestDataGeneratorController.h>
#import <FolderManagementController.h>
#import <TagManagementController.h>
#import <ContextManagementController.h>

@interface WellDone_AppDelegate : NSObject 
{
    IBOutlet NSWindow *window;
	IBOutlet NSView* sidebarTaskPlaceholderView;
	IBOutlet NSView* simpleListPlaceholderView;
	IBOutlet NSView* sidebarFolderPlaceholderView;
	
	
	IBOutlet NSPanel* foldermanagement;
    
	SidebarTaskController* sidebarTaskController;
	SimpleListController* simpleListController;
	SidebarFolderController* sidebarFolderController;
	GTDListController* gtdListController;
	FolderManagementController* foldermanagementController;
	TagManagementController* tagmanagementController;
	ContextManagementController* contextmanagementController;
	
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) SimpleListController *simpleListController;

- (IBAction)saveAction:sender;
- (IBAction) changeViewController:(id)sender;
- (void)showTestdatagenerator:(id)sender;
- (void)showFolderManagement:(id)sender;
- (void)showTagManagement:(id)sender;
- (void)showContextManagement:(id)sender;

@end

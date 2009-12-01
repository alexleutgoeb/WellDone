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
#import <PrioritySplitViewDelegate.h>

@class TDApi, SyncManager;

@interface WellDone_AppDelegate : NSObject {
    IBOutlet NSWindow *window;
	IBOutlet NSSplitView *splitView;
	PrioritySplitViewDelegate *splitViewDelegate;
 	IBOutlet NSView* sidebarTaskPlaceholderView;
	IBOutlet NSView* simpleListPlaceholderView;
	IBOutlet NSView* sidebarFolderPlaceholderView;
	
	//is necessary for setting the first responder (focus) to the current view, e.g. after inserting new task:
	NSView* currentListView;
	
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
	
@private
	NSMutableDictionary *syncServices;
	SyncManager *syncManager;
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
- (void)addNewTask:(id)sender;

@end

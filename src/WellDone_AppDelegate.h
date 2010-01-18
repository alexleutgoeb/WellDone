//
//  WellDone_AppDelegate.h
//  WellDone
//
//  Created by Alex Leutgöb on 27.10.09.
//  Copyright alexleutgoeb.com 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SidebarTaskController.h"
#import "SimpleListController.h"
#import "GTDListController.h"
#import "SidebarFolderController.h"
#import "TestDataGeneratorController.h"
#import "FolderManagementController.h"
#import "TagManagementController.h"
#import "ContextManagementController.h"
#import "ContextViewController.h"
#import "SS_PrefsController.h"
#import "HUDTaskEditorController.h"
#import "SyncController.h"
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "DateTimePopupController.h"
#import "ConflictResolverController.h"

#define kReachabilityChangedNotification @"kNetworkReachabilityChangedNotification"
#define kNewDayNotification @"kNewDayNotification"


@interface WellDone_AppDelegate : NSObject<SyncControllerDelegate> {
    
	// Main layout
	IBOutlet NSWindow *window;
	IBOutlet NSSplitView *splitView;
	
	// Placeholder views
 	IBOutlet NSView* sidebarTaskPlaceholderView;
	IBOutlet NSView* simpleListPlaceholderView;
	IBOutlet NSView* sidebarFolderPlaceholderView;
	IBOutlet NSView* contextPlaceholderView;
	
	// Connections to required Views
	NSView* currentListView;
	IBOutlet NSPanel* foldermanagement;
	
	// View items
	IBOutlet NSProgressIndicator *syncProgress;
	IBOutlet NSButton *syncButton;
	NSMenuItem *syncMenuItem;
	NSMenuItem *syncTextMenuItem;
	IBOutlet NSTextField* quickAddTask;
	NSStatusItem *menuBarItem;
	
	// Controllers
	SidebarTaskController *sidebarTaskController;
	SimpleListController *simpleListController;
	SidebarFolderController *sidebarFolderController;
	GTDListController *gtdListController;
	FolderManagementController *foldermanagementController;
	TagManagementController *tagmanagementController;
	ContextManagementController *contextmanagementController;
	ContextViewController *contextViewController;
	HUDTaskEditorController *hudTaskEditorController;
	SyncController *syncController;
	ConflictResolverController *conflictResolverController;
	SS_PrefsController *preferencesController;
	
	// Data model support
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	// Application State
	BOOL showGTDView; 
	BOOL loadSection;
	NSDate *today;
	NSTimer *secondsTimer;
	NSTimer *autoBackupTimer;
	NSDateFormatter *dateFormatter;
	BOOL isOnline;
	SCNetworkReachabilityRef reachRef;
}

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) SimpleListController *simpleListController;
@property (nonatomic, retain, readonly) GTDListController *gtdListController;
@property (nonatomic, retain, readonly) ContextViewController *contextViewController;
@property (nonatomic, retain, readonly) NSURL *coreDataDBLocationURL;
@property (nonatomic, retain, readonly) NSURL *backupDBLocationURL;
@property (nonatomic, retain, readwrite) NSTimer *autoBackupTimer;
@property (nonatomic, assign) BOOL isOnline;

// View manipulation
- (IBAction)changeViewController:(id)sender;
- (IBAction)toggleInspector:(id) sender;
- (void)showTestdatagenerator:(id)sender;
- (void)showFolderManagement:(id)sender;
- (void)showTagManagement:(id)sender;
- (void)showContextManagement:(id)sender;
- (IBAction)showPreferencesWindow:(id)sender;
- (IBAction)filterTaskListByTitle:(id)sender;
- (void)initGTDView;

// Data manipulation
- (IBAction)startSync:(id)sender;
- (IBAction)newTaskAction:(id)sender;
- (IBAction)newFolderAction:(id)sender;
- (void)addNewTask:(id)sender;

// Helper methods for other views
- (SyncController *)sharedSyncController;
- (NSString *)applicationSupportDirectory;

@end

void networkStatusDidChange(SCNetworkReachabilityRef name, SCNetworkConnectionFlags flags, void * info);

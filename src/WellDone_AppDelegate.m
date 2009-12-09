//
//  WellDone_AppDelegate.m
//  WellDone
//
//  Created by Alex Leutgöb on 27.10.09.
//  Copyright alexleutgoeb.com 2009 . All rights reserved.
//

#import "WellDone_AppDelegate.h"
#import "SidebarTaskController.h"
#import "SimpleListController.h"
#import "GTDListController.h"
#import "SidebarFolderController.h"
#import "FolderManagementController.h"
#import "TagManagementController.h"
#import "ContextManagementController.h"
#import "TDApi.h"
#import "SyncManager.h"


#define LEFT_VIEW_INDEX 0
#define LEFT_VIEW_PRIORITY 2
#define LEFT_VIEW_MINIMUM_WIDTH 200.0
#define MAIN_VIEW_INDEX 1
#define MAIN_VIEW_PRIORITY 0
#define MAIN_VIEW_MINIMUM_WIDTH 200.0
#define RIGHT_VIEW_INDEX 2
#define RIGHT_VIEW_PRIORITY 1
#define RIGHT_VIEW_MINIMUM_WIDTH 200.0


// Anonymous class category for private methods and properties
@interface WellDone_AppDelegate ()

@property (nonatomic, retain) NSMutableDictionary *syncServices;
@property (nonatomic, retain) SyncManager *syncManager;

- (void) replacePlaceholderView:(NSView**)placeHolder withViewOfController:(NSViewController*)viewController;

@end


@implementation WellDone_AppDelegate

@synthesize simpleListController;
@synthesize syncManager, syncServices;


#pragma mark -
#pragma mark Initialization & disposal


- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	
	// Init available sync services and add to list
	self.syncServices = [[NSMutableDictionary alloc] init];
	[syncServices setObject:[TDApi class] forKey:[TDApi identifier]];
	
	
	/////////////////////////////////////////////////
	
	// Für Überschreiben der lokalen fodler mit remote folder die 4 Zeilen 
	// unkommentieren und user und password in zeile 69 eintragen.
	
	// Init sync manager
	
	// self.syncManager = [[SyncManager alloc] init];
	// NSError *error = nil;
	// [syncManager registerSyncService:[[TDApi alloc] initWithUsername:@"" password:@"" error:&error]];
	// NSManagedObjectContext *c = [syncManager replaceLocalDataWithRemoteData:self.managedObjectContext];
	
	/////////////////////////////////////////////////
	
	
}

/**
 Implementation of dealloc, to release the retained variables.
 */
- (void)dealloc {
	[syncServices removeAllObjects];
	[syncServices release];
	[syncManager release];
	
    [window release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
    [super dealloc];
}

- (void) awakeFromNib {
	// A couple of asserts to make sure the nib is properly assigned. These are easily
	// forgotten and may take some time to verify.
	NSAssert(sidebarTaskPlaceholderView != nil, @"Forgot to link the sidebarTask placeholder view!");
	NSAssert(simpleListPlaceholderView != nil, @"Forgot to link the gtdList placeholder view!");
	NSAssert(sidebarFolderPlaceholderView != nil, @"Forgot to link the sidebarFolder placeholder view!");
	
	// When the main window is loaded from nib, we create our children views. This
	// loads the views from their nibs so we can access their data. Note that in apps
	// that use many custom views, we don't have to load all at once. Instead we should
	// lazily load the subviews (i.e. create the view controllers) when they are needed.
	// This should speed up the application loading time . Note that we don't have to 
	// assert the actual views IB mapping since that is done by NSViewController.
	
	simpleListController = [[SimpleListController alloc] init];
	gtdListController = [[GTDListController alloc] init];
	sidebarTaskController = [[SidebarTaskController alloc] init];
	sidebarFolderController = [[SidebarFolderController alloc] init];
	
	// Replace the placeholder views with the actual views from the controllers.
 	[self replacePlaceholderView:&sidebarFolderPlaceholderView withViewOfController:sidebarFolderController];
	[self replacePlaceholderView:&simpleListPlaceholderView withViewOfController:simpleListController];
	[self replacePlaceholderView:&sidebarTaskPlaceholderView withViewOfController:sidebarTaskController];
	
	
	splitViewDelegate =
	[[PrioritySplitViewDelegate alloc] init];
	
	[splitViewDelegate
	 setPriority:LEFT_VIEW_PRIORITY
	 forViewAtIndex:LEFT_VIEW_INDEX];
	[splitViewDelegate
	 setMinimumLength:LEFT_VIEW_MINIMUM_WIDTH
	 forViewAtIndex:LEFT_VIEW_INDEX];
	[splitViewDelegate
	 setPriority:MAIN_VIEW_PRIORITY
	 forViewAtIndex:MAIN_VIEW_INDEX];
	[splitViewDelegate
	 setMinimumLength:MAIN_VIEW_MINIMUM_WIDTH
	 forViewAtIndex:MAIN_VIEW_INDEX];
	[splitViewDelegate
	 setPriority:RIGHT_VIEW_PRIORITY
	 forViewAtIndex:RIGHT_VIEW_INDEX];
	[splitViewDelegate
	 setMinimumLength:RIGHT_VIEW_MINIMUM_WIDTH
	 forViewAtIndex:RIGHT_VIEW_INDEX];
	
	
	[splitView setDelegate:splitViewDelegate];
}



/*
 
#pragma mark User actions

- (IBAction) saveAction:(id)sender
{
	NSError *error = nil;
	if (![[self managedObjectContext] save:&error])
	{
		[NSApp presentError:error];
	}
}
*/

#pragma mark -
#pragma mark PrivateAPI

/*
 Replace the given placeholder view with the view of the given NSViewController.
 placeholder: give a pointer to the pointer to the placeholder NSView
 locationCode: 1 for folder view, 2 for task view, 3 for right sidebar
*/
- (void) replacePlaceholderView:(NSView**)placeholder withViewOfController:(NSViewController*)viewController
{
	NSParameterAssert(viewController != nil);
	NSParameterAssert(*placeholder != nil);
	
	NSView *newView = [viewController view];
	NSView *superview = [*placeholder superview];
	
	// Copy the relevant settings from placeholder to the view.
	[newView setFrame:[*placeholder frame]];
	[newView setAutoresizingMask:[*placeholder autoresizingMask]];
	
	// Replace the placeholder with the actual view.
	[superview replaceSubview:*placeholder with:newView];
	
	*placeholder = newView;
}

#pragma mark CoreData handling

/**
    Returns the support directory for the application, used to store the Core Data
    store file.  This code uses a directory named "WellDone" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */
- (NSString *)applicationSupportDirectory {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"WellDone"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The directory for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator) return persistentStoreCoordinator;

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
	NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"WellDone.welldonedoc"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
												  configuration:nil 
															URL:url 
														options:nil 
														  error:&error]){//change between XML and DB saved local
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    

    return persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext) return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];

    return managedObjectContext;
}

/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

/*
// Called after start
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	DLog(@"Debug log message.");
	mainWindowController = [[MainWindowController alloc] init];
	[mainWindowController showWindow: nil];
}
 */


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    if (!managedObjectContext) return NSTerminateNow;

    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }

    if (![managedObjectContext hasChanges]) return NSTerminateNow;

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
    
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.

        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
                
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;

        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;

    }

    return NSTerminateNow;
}


/**
  Implements the First responder chain call for "showTestdatagenerator". The corresponding controller is initialized
  and the window is shown.
 */
- (void)showTestdatagenerator:(id)sender {
	TestDataGeneratorController *testDataGeneratorController = [[TestDataGeneratorController alloc] init];
	[[testDataGeneratorController window] orderFront:self];
}

/**
  Shows the Folder Management Window after the Context Menu is clicked.
 */
- (void)showFolderManagement:(id)sender {
	foldermanagementController = [[FolderManagementController alloc] init];
	[[foldermanagementController window] orderFront:self];
}

/**
 Shows the Tag Management Window after the Context Menu is clicked.
 */
- (void)showTagManagement:(id)sender {
	tagmanagementController = [[TagManagementController alloc] init];
	[[tagmanagementController window] orderFront:self];
}

/**
 Shows the Context Management Window after the Context Menu is clicked.
 */
- (void)showContextManagement:(id)sender {
	contextmanagementController = [[ContextManagementController alloc] init];
	[[contextmanagementController window] orderFront:self];
}

- (IBAction) changeViewController:(id) sender {
	static int selectedSegment = -1;
	if ([sender isKindOfClass:[NSSegmentedControl class]]) {
		selectedSegment = [sender selectedSegment];
		
		if (selectedSegment == 0) {
			NSLog(@"Debug: replace gtdlistview with simplelistview");
			[self replacePlaceholderView:&simpleListPlaceholderView withViewOfController:simpleListController];
		} else if (selectedSegment == 1) {
			NSLog(@"Debug: replace simplelistview with gtdlistview");
			[self replacePlaceholderView:&simpleListPlaceholderView withViewOfController:gtdListController];
		}
	}

}

- (void)addNewTask:(id)sender {
	NSManagedObject *task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:managedObjectContext]; 
	NSString *title = [sender stringValue];
	[task setValue:title forKey:@"title"]; 
	[sender setStringValue:@""];
	[window makeFirstResponder:currentListView];
}



@end

//
//  SidebarFolderController.m
//  WellDone
//
//  Created by Manuel Maly on 06.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SidebarFolderController.h"
#import "WellDone_AppDelegate.h"

#define rootNodeInbox			@"1"
#define nodeInbox				@"1.1"
#define rootNodeTaskFolders		@"2"

@implementation SidebarFolderController


#pragma mark -
#pragma mark Initialization

- (id) init
{
	self = [super initWithNibName:@"FolderSourceListView" bundle:nil];
	if (self != nil)
	{		
	}
	return self;
}

- (void) awakeFromNib {
	moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
	[sidebar setDefaultAction:@selector(buttonDefaultHandler:) target:sidebar];
	[sidebar setViewController:self];
	// Sub Delegates & Data Source
	[sidebar setDataSource:sidebar];
	[sidebar setDelegate:sidebar];
	
	// Insert initial root nodes
	[self initRootNodes];
	
	// Insert nodes from persistent store
	[self initFolderListFromStore];
	
	// Initialize listening to notifications by managedObjectContext
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
		   selector:@selector(reactToMOCSave:)
			   name:NSManagedObjectContextDidSaveNotification
			 object:nil];
}


/*
 * Initialize all root nodes which group items in the source list view.
 */
- (void) initRootNodes {
	[sidebar addSection:rootNodeInbox caption:@"INBOX"];
	[sidebar addChild:rootNodeInbox 
				  key:nodeInbox
			  caption:@"Inbox"
				 icon:[NSImage imageNamed:@"inbox.png"]	
				 data: nil
			   action:@selector(handleInboxSelection:) 
			   target:self];
	
	[sidebar addSection:rootNodeTaskFolders caption:@"FOLDERS"];
	[sidebar reloadData];
	

	
	// Expand all sections' nodes
	[sidebar expandItem:rootNodeInbox];
	[sidebar expandItem:rootNodeTaskFolders];
	
	[sidebar selectItem:nodeInbox];
}

/*
 * Initialize the folder list from the store.
 */
- (void)initFolderListFromStore {
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Folder" inManagedObjectContext:moc];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deletedByApp == %@", [NSNumber numberWithInt:0]];
	
	[request setPredicate:predicate];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"order" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	NSError *error;
	NSArray *folders = [moc executeFetchRequest:request error:&error];
	if (folders == nil)
	{
		// TODO: Deal with error...
	}
	[self addFolders:folders toSection:rootNodeTaskFolders];
	
}

#pragma mark -
#pragma mark General Controller methods 

/* ============================================================================
 *  General Controller methods 
 */

/*
 * Save all changes done to managed objects into the persistent store.
 */
- (void) saveChangesToStore {
	NSError *error;
	if (![moc save:&error]) {
		NSLog(@"Error saving changes - error:%@",error);
	}
	
}

/*
 * This method will be called when a save-operatoin is done to the main managedObjectContext (central application delegate's moc).
 * It reacts to some of these changes with updates to the folder tree view.
 */
- (void) reactToMOCSave:(NSNotification *)notification {
	id object;
	NSDictionary *userInfo = [notification userInfo];
	
	NSEnumerator *updatedObjects = [[userInfo objectForKey:NSUpdatedObjectsKey] objectEnumerator];
	while (object = [updatedObjects nextObject]) {
		if ([object isKindOfClass: [Folder class]]) {
			[self handleUpdatedFolder: object];
			[sidebar reloadData];
		}
	}
	
	NSEnumerator *insertedObjects = [[userInfo objectForKey:NSInsertedObjectsKey] objectEnumerator];
	while (object = [insertedObjects nextObject]) {
		if ([object isKindOfClass: [Folder class]]) {
			NSLog(@"Will insert Folder with name: %@", [object name]);
			[self addFolder:object toSection:rootNodeTaskFolders];
			[sidebar reloadData];	
			[self saveFolderOrderingToStore];
		}
	}
	
	NSEnumerator *deletedObjects = [[userInfo objectForKey:NSDeletedObjectsKey] objectEnumerator];
	while (object = [deletedObjects nextObject]) {
		if ([object isKindOfClass: [Folder class]]) {
			NSLog(@"Will delete Folder with name: %@", [object name]);
			[self removeFolder: object];
			[sidebar reloadData];	
		}
	}
}

/*
 * Handles updates to the specified folder, stemming from the datasource (folder caption, deleted yes/no).
 * If the folder is found in the list, but the object from the datasource has deletedByApp == YES, the folder is deleted
 * from the list.
 * If the folder does not exist in the list (perhaps because the deleted flag was set to YES), the folder is readded
 * to the list, if the deleted flag is set to NO.
 */
- (void) handleUpdatedFolder: (Folder *) updatedFolder {
	NSLog(@"Will update Folder with name: %@", [updatedFolder name]);
	SidebarFolderNode *nodeToUpdate = [sidebar nodeForKey:[updatedFolder objectID]];
	if(nodeToUpdate == nil) {
		NSLog(@"Did not find updated Folder in folder list - maybe it has been deleted and is readded now: %@", [updatedFolder name]);
		// Folder is not in list, but it is not set deleted in datasource - add folder:
		if ([updatedFolder deletedByApp] == NO) {
			NSLog(@"Folder '%@' is added to the list, because deleted-flag is NO", [updatedFolder name]);
			[self addFolder:updatedFolder toSection:rootNodeTaskFolders];
			nodeToUpdate = [sidebar nodeForKey:[updatedFolder objectID]];
		}
		// Deleted flag is set to yes - we won't handle folders which are not in the list and 
		// are set deleted in datasource
		else {
			NSLog(@"Ignore update on folder '%@' because deleted-flag is YES and folder is not in list", [updatedFolder name]);
			return;
		}
		
	}
	
	if ([[updatedFolder deletedByApp] boolValue]) {
		NSLog(@"Delete folder '%@' from list because deleted-flag is YES", [updatedFolder name]);
		[self removeFolder: updatedFolder];
		return;
	}
	
	if (![[nodeToUpdate caption] isEqualToString:[updatedFolder name]]) {
		NSLog(@"New folder name '%@' for instead of '%@'", [updatedFolder name], [nodeToUpdate caption]);
		[nodeToUpdate setCaption:[updatedFolder name]];
	}
}

/*
 * Save all folders' orderings which are children of rootNodeTaskFolders (see header) to the store.
 * This option is preferred over fixOrderingForFolder:doSave:
 */
- (void) saveFolderOrderingToStore {
	SidebarFolderNode *parentNode = [sidebar nodeForKey: rootNodeTaskFolders];
	NSEnumerator *childrenEnum = [parentNode childrenEnumeration];
	id child;
	int counter = 0;
	while (child = [childrenEnum nextObject]) {
		counter++;
		if ([child isKindOfClass: [SidebarFolderNode class]]) {
			SidebarFolderNode *node = child;
			NSLog(@"Will save order for folder node: %@", [node caption]);
			Folder *currentListFolder = [node data];
			[currentListFolder setOrder: [[NSNumber alloc] initWithInt: counter]];
		}
	}
	[self saveChangesToStore];
	
}

- (void) addNewFolderByContextMenu {
	Folder *folder = [NSEntityDescription insertNewObjectForEntityForName:@"Folder" inManagedObjectContext:moc]; 
	folder.name = @"New Folder";
	folder.deletedByApp = [NSNumber numberWithBool:NO];
	[self saveChangesToStore];
}

- (void) deleteFolderByContextMenu: (Folder *)folderToDelete {
	folderToDelete.deletedByApp = [NSNumber numberWithBool:YES];
	id task;
	for (task in [folderToDelete tasks]) {
		if ([task deletedByApp] != [NSNumber numberWithBool:YES])
			[task setDeletedByApp:[NSNumber numberWithBool:YES]];
	}
	
	[self saveChangesToStore];
}


/*
 * CURRENTLY NOT IN USE!
 * Takes a given folder. If it has an ordering value of 0, it is seen as unordered, and it is assigned a new ordering value,
 * which is maximum(all order numbers)+1
 */
- (void) fixOrderingForFolder:(Folder *)folder doSave:(BOOL)performSave {
	if ([folder order] != nil) {
		NSNumber *orderNumber = [folder order];
		if ([orderNumber intValue] == 0) {
			NSEntityDescription *entityDescription = [NSEntityDescription
													  entityForName:@"Folder" inManagedObjectContext:moc];
			NSFetchRequest *request = [[NSFetchRequest alloc] init];
			[request setEntity:entityDescription];
			
			NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
												initWithKey:@"order" ascending:NO];
			[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
			[request setFetchLimit:1];
			NSError *error;
			NSArray *folders = [moc executeFetchRequest:request error:&error];
			if (folders == nil)
			{
				// TODO: Deal with error...
			}
			//Get folder with the highest order count
			Folder *lastFolder = [folders lastObject];
			int newOrder;
			if (lastFolder == nil) {
				newOrder = 1;
			}
			else {
				newOrder = [[lastFolder order] intValue]+1;
			}
			
			NSNumber *newOrderNumber = [[NSNumber alloc] initWithInt:newOrder];
			[folder setOrder:newOrderNumber];
			
			if(performSave) {
				[self saveChangesToStore];
			}
		}
	}
}

/*
 * Adds a new folder to the given section. The folder entity has to provide a persistent id, or else
 * it will not be added (entity has to have been saved at least once in the moc).
 */
- (void) addFolder:(Folder *) folder toSection:(NSString *)section {
	if([[folder objectID] isTemporaryID] == YES) {
		NSLog(@"New Folder has temporary objectid!");
		return;
	}
	
	[sidebar addChild:section 
			   key:[folder objectID]
		   caption:[folder name]
			  icon:[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)]	
			  data: folder
			action:@selector(handleFolderSelection:) 
			target:self];
}

/*
 * Adds multiple folders to the given section. At the end, a reload command is sent so the list reloads all nodes.
 */
- (void) addFolders: (NSArray *) folders toSection:(NSString *)section {
	id folder;
	NSEnumerator *folderEnumerator = [folders objectEnumerator];
	while (folder = [folderEnumerator nextObject]) {
		if ([folder isKindOfClass: [Folder class]]) {
			NSLog(@"Will insert Folder with name: %@", [folder name]);
			[self addFolder:folder toSection:section];			
		}
	}
	[sidebar reloadData];
}

/*
 * Adds the given folder to the currently dragged task (from SimpleList).
 */
- (void) addDraggedTaskToFolder: (Folder *) folder {
	Task *task = [simpController getDraggedTask];
	task.folder = folder;
	[self saveChangesToStore];
}

/*
 * Removes the given folder from the view.
 */
- (void) removeFolder:(Folder *) folder {
	[sidebar removeItem: [folder objectID]];
}

- (IBAction) handleFolderSelection:(id) sender {
	NSLog(@"Selected Folder '%@'", [sender caption]);
	if ([[sender data] isKindOfClass:[Folder class]]) {
		[simpController setTaskListFolderFilter:(Folder *)[sender data]];
		[gtdController setTaskListFolderFilter:(Folder *)[sender data]];
		[self sendFolderNameIndicatorChange:[(Folder *)[sender data] name]];
	}
}

- (void)sendFolderNameIndicatorChange:(NSString *)name {
	[[NSApp delegate] changeFolderNameIndicator:name];
}

- (IBAction) handleInboxSelection:(id) sender {
	NSLog(@"Selected Inbox!");
	[simpController setTaskListFolderFilter:nil];
	[gtdController setTaskListFolderFilter:nil];
	[[NSApp delegate] changeFolderNameIndicator:@"Inbox"];
}

- (void) setSimpController:(SimpleListController *) simpleListController {
	simpController = simpleListController;
}

- (void) setGTDController:(GTDListController *) gtdListController {
	gtdController = gtdListController;
}

- (Folder *) selectedFolder {
	return [sidebar selectedFolder];
}

@end

//
//  SidebarFolderController.h
//  WellDone
//
//  Created by Manuel Maly on 06.12.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SidebarFolderTreeView.h>
#import <SidebarFolderNode.h>
#import <SimpleListController.h>

@interface SidebarFolderController : NSViewController {
	IBOutlet SidebarFolderTreeView *sidebar;
	NSManagedObjectContext *moc;
	SimpleListController *simpController;
}

- (void) initFolderListFromStore;
- (void) initRootNodes;

- (void) saveChangesToStore;

- (void) reactToMOCSave:(NSNotification *)notification;
- (void) handleUpdatedFolder: (Folder *) updatedFolder;
- (void) addNewFolderByContextMenu;
- (void) deleteFolderByContextMenu: (Folder *)folderToDelete;

- (void) addFolder:(Folder *)folder toSection:(NSString *)section;
- (void) addFolders: (NSArray *) folders toSection:(NSString *)section;
- (void) removeFolder:(Folder *) folder;
- (void) saveFolderOrderingToStore;

- (IBAction) handleFolderSelection:(id) sender;
- (IBAction) handleInboxSelection:(id) sender;

- (void) setSimpController:(SimpleListController *) simpleListController;
@end

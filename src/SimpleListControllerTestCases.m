//
//  SimpleListControllerTestCases.m
//  WellDone
//
//  Created by Christian Hattinger on 09.12.09.
//  Copyright 2009 TU Wien. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@interface SimpleListControllerTestCases :SenTestCase {
	
}

//methoden

@end

@implementation SimpleListControllerTestCases

- (void)setUp {
	NSLog("@hola");
}

- (void)tearDown {
	
}


/*TODO: 
 - einen neuen tag einfuegen
 - einen task loeschen
 - mehrere tasks loeschen
 - einen bestehenden tag einfuegen (der schon in coredata ist), ist er dannach richtig
 - einen tag versuchen doppelt einzufuegen
 - mehrere tokens einfuegen, dabei ist jedoch einer schon dem task zugeordnet
 - einen token ueberschreiben (copy& paste ueber einen bestehenden)
 */
- (void) testShouldAddObjects{
		/*
		 
		 - (NSArray *)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell 
		 shouldAddObjects:(NSArray *)tokens 
		 atIndex:(NSUInteger)index{
		 */
}	
/*TODO:
	- typing of a tag that already exisits (first letters), check order of the list
	- typing of a tag where some letters exist in that order in the middle of a saved token
	- typing of a new token, check if no list is returned
	- check for upper/lower case typing (if it matters)--> should it matter?
 */
- (void) testCompletionsForSubstring{
	/*
	 - (NSArray *)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell 
	 completionsForSubstring:(NSString *)substring 
	 indexOfToken:(NSInteger)tokenIndex 
	 indexOfSelectedItem:(NSInteger *)selectedIndex {
	 */
	
}




- (void) testGetCurrentTags{
/*
 - (NSArray *) getCurrentTags {
 */

}

- void (getTagByName){
/*
 - (Tag *) getTagByName: (NSString *)tagName {

 */
}




/*
 // Tests adding a folder without a folder parameter
 - (void)testAddFolderWithoutParams {
 NSError *error = nil;
 NSInteger returnValue = [api addFolder:nil error:&error];
 STAssertTrue([error code] == GtdApiMissingParameters, @"Folder must not be added without folder argument.");
 STAssertTrue(returnValue == -1, @"Return value must be -1.");
 }
 
 // Tests adding a folder with an empty title in the folder object
 - (void)testAddFolderWithoutFolderTitle {
 NSError *error = nil;
 folder.title = nil;
 NSInteger returnValue = [api addFolder:folder error:&error];
 STAssertTrue([error code] == GtdApiMissingParameters, @"Folder must not be added without folder title argument.");
 STAssertTrue(returnValue == -1, @"Return value must be -1.");
 }
 
 // Tests deleting a folder without a folder parameter
 - (void)testDeleteFolderWithoutParams {
 NSError *error = nil;
 STAssertTrue([api deleteFolder:nil error:&error] == NO, @"Return value must be NO.");
 STAssertTrue([error code] == GtdApiMissingParameters, @"Folder must not be deleted without arguments.");
 }
 
 // Tests deleting a folder with an empty uid in the folder object
 - (void)testDeleteFolderWithoutFolderUid {
 NSError *error = nil;
 folder.uid = -1;
 STAssertTrue([api deleteFolder:folder error:&error] == NO, @"Return value must be NO.");
 STAssertTrue([error code] == GtdApiMissingParameters, @"Folder must not be deleted without uid argument.");
 }
 
 // Tests editing a folder without a folder parameter
 - (void)testEditFolderWithoutParams {
 NSError *error = nil;
 STAssertTrue([api editFolder:nil error:&error] == NO, @"Return value must be NO.");
 STAssertTrue([error code] == GtdApiMissingParameters, @"Folder must not be edited without folder argument.");
 }
 
 // Tests editing a folder with an empty uid in the folder object
 - (void)testEditFolderWithoutFolderUid {
 NSError *error = nil;
 folder.uid = -1;
 STAssertTrue([api editFolder:folder error:&error] == NO, @"Return value must be NO.");
 STAssertTrue([error code] == GtdApiMissingParameters, @"Folder must not be edited without folder uid argument.");
 }
 
 // Tests editing a folder with an empty uid in the folder object
 - (void)testEditFolderWithoutFolderTitle {
 NSError *error = nil;
 folder.title = nil;
 STAssertTrue([api editFolder:folder error:&error] == NO, @"Return value must be NO.");
 STAssertTrue([error code] == GtdApiMissingParameters, @"Folder must not be edited without folder title argument.");
 }
 */

@end

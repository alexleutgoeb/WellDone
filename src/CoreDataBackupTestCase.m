//
//  CoreDataBackupTestCase.m
//  WellDone
//
//  Created by Christian Hattinger on 07.01.10.
//  Copyright 2010 TU Wien. All rights reserved.
//

#import "CoreDataBackupTestCase.h"
#import "CoreDataBackup.h"

@implementation CoreDataBackupTestCase


-(void)testOne {	
	int value1 = 1;
	int value2 = 1; //change this value to see what happens when the 
	STAssertTrue(value1 == 
				 value2, @"Value1 != Value2. Expected %i, got %i", value1, value2);
	
	
	
}

- (void)testBackupDatabaseFile1{

	NSString *location = @"/Users/hatti/juhu";
	
	CoreDataBackup *backupEngine = [[CoreDataBackup alloc] init];

	
	[backupEngine backupDatabaseFile:location];
	

	
	int value1 = 1;
	int value2 = 1; //change this value to see what happens when the 
	STAssertTrue(value1 == 
				 value2, @"Value1 != Value2. Expected %i, got %i", value1, value2);
	
}

@end

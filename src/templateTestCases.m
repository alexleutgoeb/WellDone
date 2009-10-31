//
//  templateTestCases.m
//  WellDone
//
//  Created by Christian Hattinger on 31.10.09.
//  Copyright 2009 TU Wien. All rights reserved.
//

#import "templateTestCases.h"


@implementation templateTestCases

/* he name of the method must begin with the word "test" */
-(void)testOne {	
	/*
	 In the body of your test case methods, you must construct any data 
	 structures you need to execute the test, run the test, 
	 and then release the data structures you created. 
	 If a test succeeds, the corresponding test case method should exit normally. 
	 If a test fails, you should report the failure using one of the macros defined by the SenTestingKit framework. 
	 */
	int value1 = 1;
	int value2 = 1; //change this value to see what happens when the 
	STAssertTrue(value1 == 
				 value2, @"Value1 != Value2. Expected %i, got %i", value1, value2);
	
	
/*	These macros are defined in the SenTestCase.h header file of the framework. Some of the more commonly used macros are listed below: 
 STAssertNotNil(a1, description, ...) 
 STAssertTrue(expression, description, ...)
 STAssertFalse(expression, description, ...) 
 STAssertEqualObjects(a1, a2, description, ...)
 STAssertEquals(a1, a2, description, ...) 
 STAssertThrows(expression, description, ...)
 STAssertNoThrow(expression, description, ...)
 STFail(description, ...) */	
}



// http://developer.apple.com/mac/articles/tools/unittestingwithxcode3.html --> good link, also if we want to debug

@end

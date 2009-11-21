//
//  GTDListController.h
//  WellDone
//
//  Created by Manuel Maly on 15.11.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GTDListController : NSViewController {
	NSMutableArray *subViewControllers;

}

@property (nonatomic, retain) NSMutableArray *subViewControllers;

@end

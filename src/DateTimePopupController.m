//
//  DateTimePopupController.m
//  WellDone
//
//  Created by Manuel Maly on 14.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DateTimePopupController.h"
#import "MAAttachedWindow.h"


@implementation DateTimePopupController

- (id) init
{
	self = [super initWithNibName:@"DateTimePopup" bundle:nil];
	return self;
}

/* NSPoint buttonPoint = NSMakePoint(NSMidX([toggleButton frame]),
 NSMidY([toggleButton frame]));*/
+ (DateTimePopupController *)showPopupAtLocation:(NSPoint)location forWindow:(NSWindow *)window callBack:(SEL)callBack to:(id)callBackTarget
{
	//TODO Remove this!!
	location = NSMakePoint(NSMidX([window frame]),
									  NSMidY([window frame]));
	
	DateTimePopupController *controller = [[DateTimePopupController alloc] init];
	MAAttachedWindow *popupWindow;
	int side = 1;
    popupWindow = [[MAAttachedWindow alloc] initWithView:[controller view] 
                                            attachedToPoint:location 
                                            inWindow: window 
											onSide:side 
											  atDistance:0.0];
	[popupWindow setBorderColor: [NSColor whiteColor]]; //[borderColorWell color]];
	[popupWindow setBackgroundColor: [NSColor whiteColor]]; //[backgroundColorWell color]];
	[popupWindow setViewMargin: 0.0];//[viewMarginSlider floatValue]];
	[popupWindow setBorderWidth:2.0]; //[borderWidthSlider floatValue]];
	[popupWindow setCornerRadius:10.0]; //[cornerRadiusSlider floatValue]];
	[popupWindow setHasArrow: YES];//([hasArrowCheckbox state] == NSOnState)];
	[popupWindow setDrawsRoundCornerBesideArrow: YES]; // ([drawRoundCornerBesideArrowCheckbox state] == NSOnState)];
	[popupWindow setArrowBaseWidth: 10.0];//[arrowBaseWidthSlider floatValue]];
	[popupWindow setArrowHeight: 5.0]; //[arrowHeightSlider floatValue]];
    //[popupWindow orderFront:nil];
	[window addChildWindow:popupWindow ordered:NSWindowAbove];
	
	return controller;
}

		 
		 /*} else {
		  [[toggleButton window] removeChildWindow:attachedWindow];
		  [attachedWindow orderOut:self];
		  [attachedWindow release];
		  attachedWindow = nil;
		  }*/
		 
@end

//
//  DateTimePopupController.h
//  WellDone
//
//  Created by Manuel Maly on 14.01.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DateTimePopupController : NSViewController {
    
	/*IBOutlet NSPopUpButton *sidePopup;
    IBOutlet NSColorWell *borderColorWell;
    IBOutlet NSColorWell *backgroundColorWell;
    IBOutlet NSSlider *viewMarginSlider;
    IBOutlet NSSlider *borderWidthSlider;
    IBOutlet NSSlider *cornerRadiusSlider;
    IBOutlet NSButton *hasArrowCheckbox;
    IBOutlet NSButton *drawRoundCornerBesideArrowCheckbox;
    IBOutlet NSSlider *arrowBaseWidthSlider;
    IBOutlet NSSlider *arrowHeightSlider;
    IBOutlet NSSlider *distanceSlider;
    IBOutlet NSButton *toggleButton;
    
    IBOutlet NSTextField *textField;*/
    
	//IBOutlet NSView *view;
    //MAAttachedWindow *popupWindow;
}
+ (DateTimePopupController *)showPopupAtLocation:(NSPoint)location forWindow:(NSWindow *)window callBack:(SEL)callBack to:(id)callBackTarget;

@end

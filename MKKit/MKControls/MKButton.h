//
//  MKButton.h
//  MKKit
//
//  Created by Matthew King on 5/28/11.
//  Copyright 2011 Matt King. All rights reserved.
//

#import "MKControl.h"

typedef enum {
    MKButtonTypeHelp,
    MKButtonTypeDisclosure,
    MKButtonTypeIAP,
    MKButtonTypePlastic,
    MKButtonTypeRoundedRect,
} MKButtonType;

static const float kHorizPadding                = 20.0;
static const float kDiscloserOutlinePadding     = 2.0;
static const float kHelpButtonFontSize          = 18.0;
static const float kIAPButtonFontSize           = 14.0;
static const float kPlasticButtonFontSize       = 30.0;
static const float kRoundRectButtonFontSize     = 14.0;
static const float kButtonTextPadding           = 10.0;

/**-----------------------------------------------------------------------------
 *Overview*
 
 MKButton provides specalty buttons for various use. There are currently four
 types of buttons:
 
 * `MKButtonTypeHelp` : a small round button with a question mark
 * `MKButtonTypeDisclosure` : a blue and white button that resembles iOS discloser button
 * `MKButtonTypeIAP` : a InApp Purchase button, mimics the purchase buttons from the appstore.
 * `MKButtonTypePlastic` : a button with a rounded shine, giving it a plasic look. Default tint is black.
 * `MKButtonTypeRoundedRect` : a rounded rect button that can be assigned a color. Default tint is blue.
 
 *Graphic Display*
 
 Some MKButton types support graphics from the MKGraphicStructures class. Diffent types look
 for different parts of a graphic structure. If no graphics stucture is provide the buttons
 will default to a standard graphics structure.
 
 MKButtonTypePlastic looks for the following graphics properties:

 * fill : `default is black`
 * border : `default is black`
 
 MKButtonTypeRoundedRect
 
 * top : `default is blue with 0.5 alpha`
 * bottom : `default is blue`
 * touched : `default is blue`
 * disabled : `default is blue with 0.25 alpha`
 * border : `default is black`
 * bordered : `default is YES`
 * borderWidth : `default is 2.0`
 
 MKButtonHelp, MKButtonDisclosure, and MKButtonIAP are drawn with a preset graphic structure, and do not
 respond an assigned graphics structure.
 
 *Required Frameworks*
 
 * Foundation
 * UIKit
 * Quartz Core
 
 *Required Classes*
 
 * MKControl
------------------------------------------------------------------------------*/

@interface MKButton : MKControl {
    MKButtonType mType;
    NSString *mButtonText;

@private
    UILabel *mButtonLabel;
    
    struct {
        //bool isWorking;
        //bool isHighlighted;
        //CGColorRef tintColor;
        CGFloat fontSize;
    } MKButtonFlags;
}

///------------------------------------------------------
/// @name Creating
///------------------------------------------------------

/** 
 Returns and instance of MKButton
 
 @param type the type of button to use
 
 @param title the text of the button
 
 @return MKButton Instance
*/
- (id)initWithType:(MKButtonType)type;

/**
 Returns and instance of MKButton
 
 @param type the type of button to use
 
 @param title the text of the button
 
 @return MKButton Instance
*/
- (id)initWithType:(MKButtonType)type title:(NSString *)title;

/**
 *METHOD DEPRECATED*
*/
- (id)initWithType:(MKButtonType)type title:(NSString *)title tint:(UIColor *)tint MK_DEPRECATED_0_9;

/**
 Returns and instance of MKButton
 
 @param type the type of button to use
 
 @param title the text of the button
 
 @param graphics the graphics structure to use when drawing this button or `nil` for the default
 graphics set. 
 
 @return MKButton Instance
*/
- (id)initWithType:(MKButtonType)type title:(NSString *)title graphics:(MKGraphicsStructures *)graphics;


///---------------------------------------------------------
/// @name Elements
///---------------------------------------------------------

/** the text to display on the button */
@property (nonatomic, copy) NSString *buttonText;

///---------------------------------------------------------
/// @name Behaviors
///---------------------------------------------------------

/** Type the Button Type */
@property (nonatomic, assign) MKButtonType type;

/** *DEPRECIATED* */ 
@property (nonatomic, retain) UIColor *tintColor MK_DEPRECATED_0_9;

/** The size of the font on the button */
@property (nonatomic, assign) CGFloat fontSize;

/** The font color of the button text */
@property (nonatomic, retain) UIColor *fontColor;
           
@end

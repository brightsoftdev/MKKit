//
//  MKBarButtonItem.h
//  MKKit
//
//  Created by Matthew King on 6/18/11.
//  Copyright 2011 Matt King. All rights reserved.
//

#import "MKControl.h"
#import "MKControl+Internal.h"

typedef enum {
    MKBarButtonItemIcon,
    MKBarButtonItemBackArrow,
    MKBarButtonItemForwardArrow,
} MKBarButtonItemType;

@class MKImage;

/**----------------------------------------------------------------------------
 *Overview*
 
 MKBarButtonItem creates buttons for use on a tab bar. The button that will be displayed
 depends on the MKBarButtonItemType that is set. Currently There are three types:
 
 * `MKBarButtonItemIcon` : a button created from an image. Use initWithIcon method
 to for this type.
 * `MKBarButtonItemBackArrow` : a triangle pointing to the left.
 * `MKBarButtonItemForwardArrow`  : a triangle pointing to the right.
 
 *MKGraphics support*
 
 MKGraphicsSturctures are supported by MKBarButtonItem instances. Use the initWithType:graphics
 method to set a MKGraphicsStructures instance. If you are not using graphics your can pass `nil` 
 for the graphics parameter and a default graphic structure will be created, or create you own and 
 set it to the graphicStructure property. Instaces will look for the following properties of 
 MKGraphicsSturctures:
 
 * topColor : `default nil`
 * bottomColor : `default nil`
 * fillColor : `default white`
 * disabledColor : `default white with 0.5 alpha`
 * touchColor : `default white`
 * borderColor : `default nil`
 * usesLinerShineColor : `default NO`
 * boarderd : `default NO`
 * boarderWidth : `default 0.0`
 
 @warning *Note* When using an image for the button any graphic support is not used. Assign the 
 graphic to the MKImage instance is you would like to use it.
 
 *Required Frameworks*
 
 * Foundation
 * UIKit
 * Quartz Core
 
 *Required Classes
 
 * MKControl
 * MKImage
------------------------------------------------------------------------------*/

@interface MKBarButtonItem : MKControl {
    MKBarButtonItemType mType;
    
@private
    struct {
        BOOL requiresDrawing;
        BOOL isBordered;
    } MKBarButtonItemFlags;
}

///-----------------------------------------
/// @name Creating
///-----------------------------------------

/** *DEPRECATED v0.9* */
- (id)initWithType:(MKBarButtonItemType)type MK_DEPRECATED_0_9;

/**
 Returns an intialized instance of MKBarButtonItem, sets the MKBarButtonItemType,
 and creates the required MKGraphicsStructures instance.
 
 @param type the type of button to be displayed
 
 This parameter takes one of two types:
 
 * `MKBarButtonItemBackArrow` : a triangle pointing to the left.
 * `MKBarButtonItemForwardArrow` : a triangle pointing to the right.
 
 @param an instance of MKGraphicsStructures of `nil` for the default graphic 
 settings (see above in class overview).
 
 @return MKBarButtonItem instance
*/
- (id)initWithType:(MKBarButtonItemType)type graphics:(MKGraphicsStructures *)graphics;
/**
 Creates an instace of MKBarButtonItem from an image.
 
 @param icon the image to use for the button
 
 @return MKBarButtonItem instance
*/
- (id)initWithIcon:(MKImage *)icon;

///------------------------------------------
/// @name Types
///------------------------------------------

/** The type of button that is assigned */
@property (nonatomic, assign) MKBarButtonItemType type;

@end

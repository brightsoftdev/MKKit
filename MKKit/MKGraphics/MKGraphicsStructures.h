//
//  MKGraphicsStructures.h
//  MKKit
//
//  Created by Matthew King on 9/18/11.
//  Copyright (c) 2010-2011 Matt King. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MKKit/MKKit/MKObject.h>
#import <MKKit/MKKit/MKObject+Internal.h>

#import "MKGraphicFactory.h"
#import "UIColor+MKGraphics.h"

typedef struct {
    CGFloat width;
    CGColorRef color;
} MKGraphicsBorder;

typedef struct {
    CGSize offset;
    CGFloat blur;
    CGColorRef color;
} MKGraphicsShadow;

MKGraphicsBorder MKGraphicBorderMake(CGFloat width, UIColor *color);
MKGraphicsShadow MKGraphicShadowMake(CGSize offset, CGFloat blur, UIColor *color);

/**--------------------------------------------------------------------------
 *Overview*
 
 MKGraphicsStructures stores graphic elements to help with uniformity across
 an application.
 
 *Usage*
 
 MKKit class that use the MKGraphicsStructures class will refereance an instance
 when preforming drawing operations. 
 
 The Following Classes currently support the use of Graphics Structures:
 
 * MKBarButtonItem
 * MKButton
 * MKImage
 * MKPaging
 * MKPopOverView
 * MKView
 
 @warning *Note* Not all classes that support MKGraphicsStructures use every graphic
 property.  Check the documentaion of the individual classes to see which properies 
 they use.
 
 *Required Classes*
 
 * MKObject
 
 *Required Frameworks*
 
 * Foundation
 * UIKit
 * Core Graphics
--------------------------------------------------------------------------*/

@interface MKGraphicsStructures : MKObject {
@private
    BOOL mBordered;
    BOOL mShadowed;
    MKGraphicsBorder mBorder;
    MKGraphicsShadow mShadow;
}

///-----------------------------------------
/// @name Creating
///-----------------------------------------

/**
 Creates an autoreleasing empty instance.
 
 return MKGraphicsStructure instance
*/
+ (id)graphicsStructure;

/** *DEPRECIATED v0.9* */
+ (id)linearGradientWithTopColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor MK_DEPRECATED_0_9;

///------------------------------------------
/// @name Assigning Structures
///------------------------------------------

/** *DEPRECIATED v0.9* */
- (void)assignGradientTopColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor MK_DEPRECATED_0_9;

///-------------------------------------------
/// @name Coloring
///-------------------------------------------

/** the top color of the gradient */
@property (nonatomic, retain) UIColor *topColor;

/** the bottom color of the gradient */
@property (nonatomic, retain) UIColor *bottomColor;

/** the fill color of an UI object. */
@property (nonatomic, retain) UIColor *fillColor;

///-------------------------------------------
/// @name Contol Colors
///-------------------------------------------

/** the color of a disabled object */
@property (nonatomic, retain) UIColor *disabledColor;

/** the color of a touched object */
@property (nonatomic, retain) UIColor *touchedColor;

///--------------------------------------------
/// @name Shining
///--------------------------------------------

/** `YES` if a liner shine should be used on view drawing. */
@property (nonatomic, assign) BOOL useLinerShine;

///--------------------------------------------
/// @name Boarders
///--------------------------------------------

/** `YES` if an object should have a border drawn for it. Default is `NO`, 
 property is changed to `YES` when border is set.*/
@property (nonatomic, readonly) BOOL bordered;

/** Set a border for the drawing use the MKGrpahicsBorderMake(CGFloat width, UIColor *color) 
 funtion to create a border. */
@property (nonatomic, assign) MKGraphicsBorder border;

///--------------------------------------------
/// @name Shadows
///--------------------------------------------

/** `YES` if a shadow should be drawn. Default is `NO`, property is 
 is changed to `YES` when a shadow is set.*/
@property (nonatomic, readonly) BOOL shadowed;

/** Sets a shadow to be drawn on the view/contontol. Use the 
 MKGraphicsShadowMake(CGSize offset, CGFloat blur, UIColor *color) to 
 created a shadow. */
@property (nonatomic, assign) MKGraphicsShadow shadow;

@end 

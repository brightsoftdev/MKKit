//
//  MKGraphicsStructures.h
//  MKKit
//
//  Created by Matthew King on 9/18/11.
//  Copyright (c) 2010-2011 Matt King. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import <MKKit/MKKit/MKObject.h>
#import <MKKit/MKKit/MKObject+Internal.h>

#import "MKGraphicFactory.h"
#import "UIColor+MKGraphics.h"

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
 * MKView
 
 *Required Classes*
 
 * MKObject
 
 *Required Frameworks*
 
 * Foundation
 * UIKit
 * Core Graphics
--------------------------------------------------------------------------*/

@interface MKGraphicsStructures : MKObject {

}

///-----------------------------------------
/// @name Creating
///-----------------------------------------

/**
 Creates an autoreleasing empty instance.
 
 return MKGraphicsStructure instance
*/
+ (id)graphicsStructure;

/**
 An instance of MKGraphisStructures that sets the colors for a linear gradient.
 
 @param topColor the color on the top of the gradient.
 
 @param bottomColor the color on the bottom of the gradient.
 
 @return MKGraphicsStructure instance
*/
+ (id)linearGradientWithTopColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor;

///------------------------------------------
/// @name Assigning Structures
///------------------------------------------

/**
 Assigns colors for a linear gradient
 
 @param topColor the color on the top of the gradient.
 
 @param bottomColor the color on the bottom of the gradient.
*/
- (void)assignGradientTopColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor;

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

/** `YES` if an object should have a border drawn for it. */
@property (nonatomic, assign) BOOL bordered;

/** the border color for an object */
@property (nonatomic, retain) UIColor *borderColor;

/** The width of a border if any. Default is `2.0`. */
@property (nonatomic, assign) float borderWidth;

///--------------------------------------------
/// @name Shadows
///--------------------------------------------

/** `YES` if a shadow should be drawn. */
@property (nonatomic, assign) BOOL shadowed;

/** The size of a shadows offset */
@property (nonatomic, assign) CGSize shadowOffset;

/** The blur of a shadow 0.0 is solid line */
@property (nonatomic, assign) CGFloat shadowBlur;

/** The color of a shadow */
@property (nonatomic, retain) UIColor *shadowColor;

@end 

//
//  MKImage.h
//  MKKit
//
//  Created by Matthew King on 12/3/11.
//  Copyright (c) 2011 Matt King. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MKKit/MKKit/MKGraphics/MKGraphics.h>

/**-----------------------------------------------------------------------
 *Overview*
 
 MKImage is a subclass of UIImage that addes the abillity to create masks
 of images and color them the desired color.
 
 MKImage does support HiRes images.
 
 *Drawing Support*
 
 MKImage intances are supported by MKGraphicsStrutures. GraphicStrutures can
 be passes to images during their creation. Since MKImages are non-mutable 
 objcets, the class does not conform to the MKGraphicsFactory protocol. MKImage
 looks for the following graphic properties:
 
 * fillColor : `default black`
 * topColor : `default nil`
 * bottomColor : `default nil`
 * useLinerShine : `default NO`
 * shadowColor : `default nil`
 * shadowOffset : `default nil`
 
 *Required Frameworks*
 
 * UIKit
 * Foundation
 * Core Graphics
 
 *Required Classes* 
 
 * MKGraphics
 * MKGraphicsStructures
------------------------------------------------------------------------*/

@interface MKImage : UIImage {
    
}

///------------------------------------------
/// @name Creating
///------------------------------------------

/**
 Creates an Instace of MKImage.
 
 @param imageName the name of the image you want to mask
 
 @param color the color to make the image
 
 @return MKImage instance
*/
+ (id)imagedNamed:(NSString *)imageName graphicStruct:(MKGraphicsStructures *)graphicStruct;

/**
 Creates an Instance of MKImage.
 
 @param path the path of the image you want to mask
 
 @param color the color to make the image
 
 @return MKImage instance
*/
- (id)initWithContentsOfFile:(NSString *)path graphicStruct:(MKGraphicsStructures *)graphicStruct;

@end

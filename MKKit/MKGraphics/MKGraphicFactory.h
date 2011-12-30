//
//  MKGraphicFactory.h
//  MKKit
//
//  Created by Matthew King on 12/25/11.
//  Copyright (c) 2011 Matt King. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKGraphicsStructures;

/**-----------------------------------------------------------------------
 *Overview*
 
 MKGraphicsFractory provides method to Create MKKit UI objects that support
 the Use of MKGraphicStructures.
------------------------------------------------------------------------*/
@protocol MKGraphicFactory <NSObject>

@required

///------------------------------------
/// @name Creating Instances
///------------------------------------

/**
 Craetes an instance of a MKKit UI object and assigns it a graphics Structure
 with the given instance
 
 @param graphicsStucture an instance of MKGraphicsStructures.
 
 @return MKKit UI object Instance
*/
- (id)initWithGraphics:(MKGraphicsStructures *)graphicsStructure;

///-------------------------------------
/// @name Referencing
///-------------------------------------

/** The MKGraphiceStructure that is currently in use. */
@property (nonatomic, retain) MKGraphicsStructures *graphicsStructure;

@end

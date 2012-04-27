//
//  MKControl+MKTableCell.h
//  MKKit
//
//  Created by Matt King on 4/26/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKControl.h"

/**--------------------------------------------------------------------------
 This catagory of MKControl provides the control for table cell accessories.
 ---------------------------------------------------------------------------*/
@interface MKControl (MKTableCell)

///------------------------------------------
/// @name Creating
///------------------------------------------

/**
 Retuns an istance for the specified type.
 
 @param type the type of accessory to create
 
 @return MKControl instance
 */
- (id)initWithType:(int)type;

/**
 Returns an instance that displays the specified image.
 
 @param image the image to display as the cells accessory
 
 @return MKControl instance
 */
- (id)initWithImage:(UIImage *)image;

///----------------------------------------
/// @name Type
///----------------------------------------

/** Reference to the MKTableCellAccessoryViewType */
@property (nonatomic, assign) id viewType;

@end


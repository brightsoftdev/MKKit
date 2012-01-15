//
//  MKView+MKTableHeader.h
//  MKKit
//
//  Created by Matthew King on 1/2/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKView.h"

@interface MKView (MKTableHeader)

///---------------------------------------------
/// @name Creating
///---------------------------------------------

/** *DEPRECATED v1.0* */
- (id)initWithTitle:(NSString *)title type:(MKTableHeaderType)type MK_DEPRECATED_1_0;

/**
 Returns an instace of MKView sized for a table header. The view is a basic replication of 
 of the standard headers, except you have access to the UILabel instance.
 
 @param title the text that will display on the header.
 
 @param type the header type to return
 
 * `MKTableHeaderTypeGrouped` : Returns a header for grouped tables
 * `MKTableHeaderTypePlain` : Returns a header for plain tables
 
 @param graphics an instance of MKGraphicsStructures that controls the drawing of the view.
 
 @return MKView instance
 */
- (id)initWithTitle:(NSString *)title type:(MKTableHeaderType)type graphics:(MKGraphicsStructures *)graphics;

/** *DEPRECATED v1.0* */
+ (id)headerViewWithTitle:(NSString *)title type:(MKTableHeaderType)type MK_DEPRECATED_1_0;

/**
 Returns an instace of MKView sized for a table header. The view is a basic replication of 
 of the standard headers, except you have access to the UILabel instance.
 
 @param title the text that will display on the header.
 
 @param type the header type to return
 
 * `MKTableHeaderTypeGrouped` : Returns a header for grouped tables
 * `MKTableHeaderTypePlain` : Returns a header for plain tables
 
 @param graphics an instance of MKGraphicsStructures that controls the drawing of the view.
 
 @return MKView instance
*/
+ (id)headerViewWithTitle:(NSString *)title type:(MKTableHeaderType)type graphics:(MKGraphicsStructures *)graphics;

///---------------------------------------------
/// @name View Elements
///---------------------------------------------

/** The UILabel instance that is displayed on the view */
@property (nonatomic, retain) UILabel *titleLabel;

@end

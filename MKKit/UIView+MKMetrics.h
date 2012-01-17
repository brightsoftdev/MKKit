//
//  UIView+MKMetrics.h
//  MKKit
//
//  Created by Matthew King on 1/15/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "MKMetrics.h"

/**------------------------------------------------------------------------
 *Overview*
 
 The UIView+MKMethrics catagory adds methods to the UIView class to support
 the use of MKMetrics when laying out subviews.
//-----------------------------------------------------------------------*/

@interface UIView (MKMetrics)

///-----------------------------------
/// @name Layout
///-----------------------------------

/**
 A specific layout call for UIView instances to use. 
 
 @warning *Note* This method will not be automatically called. When using
 you should call it when the interface orientation changes.
 
 @param metrics the MKViewMetrics to layout subviews for.
*/
- (void)layoutForMetrics:(MKViewMetrics)metrics;

///-----------------------------------
/// @name Layout Settings
///-----------------------------------

/**
 Sets a size for the given metrics.
 
 @param size the size of the view.
 
 @param metrics the MKViewMetrics that corrisponds to the given size.
*/
- (void)setSize:(CGSize)size forMetrics:(MKViewMetrics)metrics;

/**
 Sets a location for the given metrics. The location point corisponds the top
 left corner of the view.
 
 @param location the location of the view.
 
 @param metrics the MKViewMetrics that corisponds to the given location.
*/
- (void)setLocation:(CGPoint)location forMetrics:(MKViewMetrics)metrics;

/**
 Sets a rect for the given metrics.
 
 @param rect the rect of the view.
 
 @param metrics the MKViewMetrics that corisponds to the given metrics.
*/
- (void)setRect:(CGRect)rect forMetrics:(MKViewMetrics)metrics;

///-----------------------------------
/// @name Reference
///-----------------------------------

/** Used by MKMetrics when the layoutSubview:forMetrics: is called */
@property (nonatomic, readonly) CGRect portraitRect;

/** Used by MKMetrics when the layoutSubview:forMetrics: is called */
@property (nonatomic, readonly) CGRect landscapeRect;

///------------------------------------
/// @name Memory
///------------------------------------

/** Cleans up after the a subview is layed out. You do not need to call
 this method directly.
*/
- (void)clearMetrics;

@end

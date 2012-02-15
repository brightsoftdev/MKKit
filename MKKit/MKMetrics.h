//
//  MKMetrics.h
//  MKKit
//
//  Created by Matthew King on 1/15/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MKObject.h"
#import "MKMacros.h"

typedef enum {
    MKMetricsPortrait,
    MKMetricsLandscape,
} MKViewMetrics;

/**-------------------------------------------------------------------------
 *Overview*
 
 MKMetrics provides a methods for the persion layout of subviews during changes
 in orientation or screen size.
 
 *Usage*
 
 Before calling any of the layout methods make sure a superview is assigned you 
 can do this by using the metricsForView: method for creating your instance, or
 assign a superview to the view property.
 
 All calls the layoutSubview:forMetrics: need to enclosed in beginLayout and 
 endLayout methods.
 
 MKMetrics works in conjunction with the UIView+MKMetrics catagory use the methods
 in this catagory to set up how subview should be layed out.
--------------------------------------------------------------------------*/

@interface MKMetrics : MKObject {

}

///---------------------------------
/// @name Create Instance
///---------------------------------

/**
 Creates an instance of MKMetrics and assigns the passed UIView to the
 view property.
 
 @param view the view that has subvies to layout
 
 @return MKMetrics instance
*/
+ (id)metricsForView:(UIView *)view;

///---------------------------------
/// @name Layout
///---------------------------------

/**
 Prepares to layout subviews
*/
- (void)beginLayout;

/**
 Will layout the given subview using the location/size set with UIView+MKMetrics
 catagory methods.
 
 @param subview the subview to layout
 
 @param metrics the metrics to use to layout the subview. You can use the following
 fuctions to find the witch MKViewMetrics to pass:
 
 * MKViewMetrics MKMetricsCurrentOrientationMetrics(void)
 * MKViewMetrics MKMetricsOrientationMetrics(UIInterfaceOrientation orientation)
*/
- (void)layoutSubview:(UIView *)subview forMetrics:(MKViewMetrics)metrics;

/**
 Cleans up after a subview layout.
*/
- (void)endLayout;

///---------------------------------
/// @name Layout Options
///---------------------------------

- (void)horizontallyCenterView:(UIView *)subview;

///---------------------------------
/// @name Referencing
///---------------------------------

/** The suberview that contains the subviews to layout. */
@property (nonatomic, retain) UIView *view;

@end

CGFloat MKMetricsWidthForOrientation(UIInterfaceOrientation orientation);
CGFloat MKMetricsWidthForMetrics(MKViewMetrics metrics);
CGFloat MKMetricsHeightForMetrics(MKViewMetrics metrics);

/// NEW
CGFloat MKMetricsGetMaxWidth(int classTag, MKViewMetrics metrics);

MKViewMetrics MKMetricsCurrentOrientationMetrics(void);
MKViewMetrics MKMetricsOrientationMetrics(UIInterfaceOrientation orientation);

static const int kMKSegmentedPopOutViewClassTag      = 1;
//
//  UIViewController+MKVIewController.h
//  MKKit
//
//  Created by Matthew King on 1/20/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKDisclosureViewController, MKSplitViewController;

/**-------------------------------------------------------------------------------
 *Overview*
 
 This category adds to methods and properties to UIViewController to give reference
 and observation control of MKViewController container controllers.
--------------------------------------------------------------------------------*/
@interface UIViewController (MKVIewController)

///----------------------------------
/// @name Related View Controllers
///----------------------------------

/** 
 Reference to an instance of MKSplitViewController. Returns `nil` is the caller
 is not a child of controller of an MKSplitViewController instance.
*/
@property (nonatomic, readonly) MKSplitViewController *dynamicSplitViewController;


@end

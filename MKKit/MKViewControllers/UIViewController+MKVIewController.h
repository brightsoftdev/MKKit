//
//  UIViewController+MKVIewController.h
//  MKKit
//
//  Created by Matthew King on 1/20/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKDisclosureViewController;

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
 The MKDisclosureViewController instance if the parent is an instance of 
 MKDisclosureViewController.
*/
@property (nonatomic, readonly) MKDisclosureViewController *disclosureController;

///-------------------------------------
/// @name Disclosure View Observations 
///------------------------------------

/**
 Called when a disclosure veiw moved onto the srceen. Override this
 method to preform any nessaray actions.
*/
- (void)didDiscloseView;

@end

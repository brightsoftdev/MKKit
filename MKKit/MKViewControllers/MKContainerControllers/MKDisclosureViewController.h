//
//  MKSlideViewController.h
//  MKKit
//
//  Created by Matthew King on 1/20/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import <MKKit/MKKit/MKViewControllers/MKViewController.h>

/**-----------------------------------------------------------------------------
 *Overview*
 
 MKDisclosureViewController is container view controller that uses two view controllers.
 The mainViewController is the first to be displayed and the diclosureViewController will
 slide in and out from the right of the screen when directed.
 
 @warning *Note* This class is still under development and not fully functional.
------------------------------------------------------------------------------*/
@interface MKDisclosureViewController : MKViewController {
@private
    UIViewController *mMainViewController;
    UIViewController *mDisclosureViewController;
    
    BOOL mDisclosureViewIsVisible;
}

///---------------------------------
/// @name Creating
///---------------------------------

/**
 Creates a new instance of MKDisclosureViewController with the given view controllers.
 
 @param mainViewController the view controller that will be first displayed.
 
 @param disclosureViewController the view controller that moves in and out from the right of the screen
 
 @return MKDisclosureViewController instance
*/
- (id)initWithMainController:(UIViewController *)mainController disclosureController:(UIViewController *)disclosureController;

///---------------------------------
/// @name View Controllers
///---------------------------------

/** The asigned main view controller */ 
@property (nonatomic, retain, readonly) UIViewController *mainViewController;

/** The disclosure view controller */
@property (nonatomic, retain, readonly) UIViewController *disclosureViewController;

///---------------------------------
/// @name Transition Control
///---------------------------------

/** 
 Moves the disclosures view controllers's view in from the right to the given distance.
 
 @param distance the distance to move the view to mesured from the left side of the srceen.
*/
- (void)uncoverByDistance:(float)distance;

/**
 Moves the disclosure view controller's view to cover the entire area.
*/
- (void)fullyUncover;

/**
 Moves the disclosure view controller's view off of the screen.
*/
- (void)recover;

/** `YES` if the disclosure view is visiable. */
@property (nonatomic, assign, readonly) BOOL disclosureViewIsVisiable;

@end

@interface MKShadowView : UIView {
@private
    
}

@end
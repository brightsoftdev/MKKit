//
//  MKSplitViewController.h
//  MKKit
//
//  Created by Matthew King on 1/29/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import <MKKit/MKKit/MKViewControllers/MKViewController.h>

/**----------------------------------------------------------------------------
 *Overview*
 
 MKSplitViewController is moch of UISplitViewController that can added to a navigation
 controller, tab bar controller or presented as a model view controller. When in 
 landscape view both views are displayed, while in portrait only the detail view
 controller is displayed.
 
 While in portrait view a back and list view button is added to the detail views 
 navigation bar.  The list button will display the title of the list view controller.
 The list button will cause the detail view to slide in from the left of the screen.
 The list view can be presented or dismissed at any time by calling the `presentListController`
 or `dismissListController` methods.
 
 MKSplitViewController is for use on iPad only.
 
 *Usage Notes*
 
 MKSplitViewController creates its own navigation bars, if it is pushed onto a navaigation
 stack it will hide the navigation controllers navigation bar and replace it with its own.
 
 The navigation navigation bars get their navigation items from the navigationItem property
 of the given view controllers.
 
 *Reqiured Classes*
 
 * MKViewController
 * MKView
 * MKMetrics
 
 *Required Catagories*
 
 * UIViewController+MKViewController
 * UIView+MKMetrics
-----------------------------------------------------------------------------*/

@interface MKSplitViewController : MKViewController {
@private
    UIViewController *mListViewController;
    UIViewController *mDetailViewController;
    BOOL mListViewIsVisable;
}

///-------------------------------------
/// @name Creation
///-------------------------------------

/**
 Creates a new instance of MKSplitviewController using the given view controllers.
 
 @param listViewController the view controller of the list view. This is typically
 a UITableViewController.
 
 @param detailViewController the view controller of the detail view
 
 @return MKSplitViewController instance
*/
- (id)initWithListViewController:(UIViewController *)listViewController detailViewController:(UIViewController *)detailViewController;

///--------------------------------------
/// @name Child View Controllers
///--------------------------------------

/** Reference to the listViewController */
@property (nonatomic, retain, readonly) IBOutlet UIViewController *listViewController;

/** Refernce to the detailViewController */
@property (nonatomic, retain, readonly) IBOutlet UIViewController *detailViewController;

///-------------------------------------
/// @name Display Controll
///-------------------------------------

/**
 Presents the List View when in portrait mode.
*/
- (void)presentListController;

/**
 Dismisses the List View when in portrait mode.
*/
- (void)dismissListController;

/** `YES` if the list view is presented. */
@property (nonatomic, readonly) BOOL listViewIsVisable;

@end
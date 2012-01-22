//
//  MKPopOutView+MKBarButtonItem.h
//  MKKit
//
//  Created by Matthew King on 12/17/11.
//  Copyright (c) 2011 Matt King. All rights reserved.
//

#import "MKPopOutView.h"

@class MKBarButtonItem;

@interface MKPopOutView (MKBarButtonItem) 

///-------------------------------
/// @name Displaying
///-------------------------------

/**
 Shows an MKPopOverView with the arrow pointing at a MKBarButtonItem.
 
 @param button the button that arrow should point at.
 
 @param view the superview of the MKPopOverView instance.
*/
- (void)showFromButton:(MKBarButtonItem *)button onView:(UIView *)view;

/**
 Adjusts the location of the pointer/view to match the button instance.
*/
- (void)adjustToButton;

@end

//
//  MKPopoutView+MKTableCell.h
//  MKKit
//
//  Created by Matthew King on 12/31/11.
//  Copyright (c) 2011 Matt King. All rights reserved.
//

#import "MKPopOutView.h"

@class MKTableCell;

@interface MKPopOutView (MKTableCell)

///------------------------------------------------------
/// @name Identifing
///------------------------------------------------------

/** The index path of the cell showing the pop out view */
@property (nonatomic, retain, readonly) NSIndexPath *aIndexPath;

///-------------------------------------------------------
/// @name Displaying
///-------------------------------------------------------

/**
 Shows the view on the screen.
 
 @param cell the cell to display the view from
 
 @param tableView the table view to disaply on
 */
- (void)showFromCell:(MKTableCell *)cell onView:(UITableView *)tableView;

///-------------------------------------------------------
/// @name Elements
///-------------------------------------------------------

/**
 Adds a MKButtonTypeDisloserButton on the right side of the popout view
 
 @param taget the object that handles actions from the button
 
 @param selector the selector to preform when the button is tapped. The 
 expected format of the selector is `-(void)mySelector:(NSIndexPath *)indexPath`.
 */
- (void)setDisclosureButtonWithTarget:(id)target selector:(SEL)selector;


@end

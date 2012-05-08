//
//  MKTableCellTextView.h
//  MKKit
//
//  Created by Matthew King on 11/6/10.
//  Copyright 2010-2012 Matt King. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MKKit/MKKit/MKTableCells/MKTableCell.h>

@class MKTableCell;

/**-----------------------------------------------------------------------
 *Overview*
 
 MKTableCellTextView provides a table cell with a UITextView nested in it.
 When the keyboard is displayed a toolbar is added above it with `Clear`
 and `Done` buttons built in.
 
 *Usage Notes*
 
 MKTableCellTextView expects a cell height of 73.0.
------------------------------------------------------------------------*/

@interface MKTableCellTextView : MKTableCell <UITextViewDelegate> {
	UITextView *mTheTextView;
}

/** Reference the UITextView instance nested in the cell. */
@property (nonatomic, retain) UITextView *theTextView;

@end

//
//  MKTableCellSlider.h
//  MKKit
//
//  Created by Matthew King on 1/24/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import <MKKit/MKKit/MKTableCells/MKTableCell.h>

/**---------------------------------------------------------------------
 *Overview*
 
 MKTableCellSlider creates a table with a UISlider placed on it for a 
 control. 
 
 *Observing Actions*
 
 This class will send messages to the `valueDidChange:forKey:` delegate
 method when the slider is moved.
 
 @warning *Note* The value of the slider is passed through the delegate
 as an instance of NSNumber.2
----------------------------------------------------------------------*/
@interface MKTableCellSlider : MKTableCell {
    
}

///-------------------------
/// @name Elements
///-------------------------

/** Reference the UISlider is displayed on the cell. */
@property (nonatomic, retain) UISlider *slider;

@end

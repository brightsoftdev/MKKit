//
//  MKTableCell.h
//  MKKit
//
//  Created by Matthew King on 3/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MKKit/MKKit/MKControls/MKContolHeaders.h>
//#import <MKKit/MKKit/MKControls/MKCheckBox.h>
#import <MKKit/MKKit/MKControls/MKTextField.h>
#import <MKKit/MKKit/MKErrorContol/MKInputValidation.h>
#import <MKKit/MKKit/MKErrorContol/MKValidator.h>
#import <MKKit/MKKit/MKDeffinitions.h>
#import <MKKit/MKKit/MKMacros.h>
#import <MKKit/MKKit/MKStrings.h>

#import "MKTableCellDelegate.h"

#define MK_TABLE_CELL_GLOBE_ICON        @"MKTableCell-Resources.bundle/GlobeIcon.png"
#define MK_TABLE_CELL_PEN_ICON          @"MKTableCell-Resources.bundle/Pen.png"
#define MK_TABLE_CELL_WARNING_ICON      @"MKTableCell-Resources.bundle/WarningIcon.png"

typedef enum {
	MKTableCellTypeNone,
	MKTableCellTypeDescription,
	MKTableCellTypeLabel,
	MKTableCellTypeScore,
	MKTableCellTypeAction,
	MKTableCellTypeButton,
} MKTableCellType;

typedef enum {
	MKTableCellAccessoryNone,
    MKTableCellAccessoryActivity,
    MKTableCellAccessoryGlobe,
	MKTableCellAccessoryInfoButton,
	MKTableCellAccessoryWarningIcon,
} MKTableCellAccessoryViewType;

@protocol MKTableCellDelegate;
@protocol MKInputValidation;

/**-------------------------------------------------------------------------------------
 An MKTableCell is a subclass UITableViewCell. MKTableCell is designed as a superClass for 
 several customized sublcasses. The MKTableCell itself creates a few basic Table Cells:
 
 * `MKTableCellTypeNone` : A blank table cell this to be used when implementing on the subclasses.
 * `MKTableCellTypeDescription` : A table cell that has two labels side by side.
 * `MKTableCellTypeLabel` : A cell with label centered on it.
 * `MKTableCellTypeScore` : A cell with a 30x30 image view and two labels side by side.
 * `MKTableCellTypeAction` : A cell with a 30x30 image view, one label, and a discloser arrow.
 * `MKTableCellTypeButton` : A cell with an image over the whole cell and a Label centered on the cell.
 
 When a MKTableCell is created it intializes an UITableViewCell with a style of UITableViewCellStyleDefault. 
 It than removes the elements of that cell and replaces them its own. If you use the UTableCellView 
 intializer instead, be sure to set the style UITableViewCellStyleDefault to keep unneeded subviews from being 
 part of the cell.
 
 MKTableCell objects have some addtional accessoy types built in:
 
 * `MKTableCellAccessoryNone` : No accessory.
 * `MKTableCellAccessoryActivity` : Displays an activity indicator as the cells accessory.
 * `MKTableCellAccessoryGlobe ` : Displays an icon of a Globe as the cells accessory.
 * `MKTableCellAccessoryInfoButton` : Displays an info button as the cells accessory.
 * `MKTableCellAccessoryWarningIcon` : Dispalays a warning icon as the cell accessory. 
 
 The MKTableCellDelegate Protocol is adopted by MKTableCell.
 
 @warning *Note* MKTableCell objects will look for resources in the 
 MKTableCell-Resources bundle. Ensure this bundle is added to your project for 
 proper function.
----------------------------------------------------------------------------------------*/

@interface MKTableCell : UITableViewCell {
	id delegate;
	id validator;
	MKTableCellType type;
	MKTableCellAccessoryViewType accessoryViewType;
	MKValidationType _validationType;
	BOOL _validating;
	
	UILabel *mTheLabel;
	UILabel *_smallLabel;
	UILabel *_dateLabel;
	UIImageView *mTheImageView;
	UIImage *mIcon;
}

///---------------------------------------------------------------------------------------
/// @name Initalizing
///---------------------------------------------------------------------------------------

/** Returns an intalized MKTableCell. 
 
 @warning *Note* If you are using one of the MKTableCell subclasses or subclassing pass MKTableCellTypeNone
 for the cellType parameter.
 
 @param cellType The type of the cell to create. 
 @param resuseIdentifier The rueseIdentifier for this type of cell.
*/
- (id)initWithType:(MKTableCellType)cellType reuseIdentifier:(NSString *)reuseIdentifier;

///---------------------------------------------------------------------------------------
/// @name Cell Types
///---------------------------------------------------------------------------------------

/** A reference the MKTableCellType set with the initalizer. */
@property (assign) MKTableCellType type;

/** Sets MKTableCellAccessoryType for the cell. */
@property (nonatomic, assign) MKTableCellAccessoryViewType accessoryViewType;

///---------------------------------------------------------------------------------------
/// @name Referencing
///---------------------------------------------------------------------------------------

/** A unique NSString that identifies the cell. This is used in most MKTableCellDelegate methods. */
@property (assign) NSString *key;

///---------------------------------------------------------------------------------------
/// @name Cell Elements
///---------------------------------------------------------------------------------------

/** A reference to the primary label of all MKTableCell Subclass that have at least on label. */
@property (nonatomic, retain) UILabel *theLabel;

/** A reference to the secondary label of all MKTableCell Subclasses that have two labels. */
@property (nonatomic, retain) UILabel *smallLabel;

/** An image view that for cells that support images */
@property (nonatomic, retain) UIImageView *theImageView;

/** The image displayed on cell that suport image views */
@property (nonatomic, retain) UIImage *icon;

///---------------------------------------------------------------------------------------
/// @name Input Validation
///---------------------------------------------------------------------------------------

/** Sets the validation type to preform. 
 
 @see validatior
 @see MKInputValidation 
*/
@property (nonatomic, assign) MKValidationType validationType;

/** YES is the cell validates user input, NO if it does not.*/
@property (nonatomic, assign, readonly) BOOL validating;

///--------------------------------------------------------------------------------------
/// @name Validation Methods
///--------------------------------------------------------------------------------------

/** Tells the validator to valiate the input using the specified type. If you set a validationType
 other than `MKValidationNone` you will not need to call this method directly.
 
 @warning *Note* The default implentation of this method does nothing. Subclasses need to overide
 it to run a validation.
 
 @see MKInputValidation
*/
- (void)validateWithType:(MKValidationType)aType;

///---------------------------------------------------------------------------------------
/// @name Adopted Protocols
///---------------------------------------------------------------------------------------

/** The MKTableCellDelegate 
 
 @see MKTableCellDelegate
*/
@property (assign) id<MKTableCellDelegate> delegate;

/** The MKInputValidator. This is automatically assigned when a validationType is set. 
 
 @warning *Note* If you want to use one of your own objects as the validator set the validation type to
 `MKValidationNone` and assign your own object to this property. The object you assign must adopt the
 MKInputValidation protocol.
 
 @see MKInputValidation
 @see validationType
*/
@property (assign) id<MKInputValidation> validator;

@end

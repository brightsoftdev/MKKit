//
//  MKPopOutView.h
//  MKKit
//
//  Created by Matthew King on 8/2/11.
//  Copyright 2010-2012 Matt King. All rights reserved.
//

#import "MKView.h"

typedef enum {
    MKPopOutAuto,
    MKPopOutAbove,
    MKPopOutBelow,
} MKPopOutViewType;

typedef enum {
    MKPopOutTableCell,
    MKPopOutBarButton,
} MKPopOutType;

CGRect rectForType(MKPopOutViewType type, CGRect rect); 
void drawPointerForType(CGContextRef context, MKPopOutViewType type, CGColorRef fill, CGFloat position, CGRect drawRect);
void drawBackgroundForRect(CGContextRef context, CGRect drawRect, CGRect innerRect, MKGraphicsStructures *graphics);

@class MKBarButtonItem;

/**----------------------------------------------------------------------------------
 *Overview*
 
 MKPopOutView provides a view that displays additional information. The view looks like 
 Apples UIMenuView. The content of the view is taken from a UIView that you provide. 
 
 *Display Options*
 There are three types of pop out views to choose from. The types control how the view
 is displayed.
 
 * `MKPopOutAuto` : will display the view above or below the item depending on its location.
 * `MKPopOutAbove` : displays the view above the item. 
 * `MKPopOutBelow` : displays the view below the item. 
 
 *Graphics*
 
 MKPopoutView supports the use of MKGraphicsStructures instances, to provide how it is 
 drawn. MKPopoutView instance will look for the following graphic properties:
 
 * fill : `default black`
 * useLinerShine : `default YES`
 
 *Listeners*
 
 MKPopOutView listens for the `MKPopOutViewShouldRemoveNotification` to remove itself. 
 ------------------------------------------------------------------------------------*/

@interface MKPopOutView : MKView {
    MKPopOutViewType mType;
    MKPopOutViewType mAutoType;
    MKPopOutType mPopOutType;
    UIView *mView;
    
    CGFloat mArrowPosition;
}

///------------------------------------------------------
/// @name Creating
///------------------------------------------------------

/**
 Returns and intialized instance of MKPopoutView
 
 @param view the content of the popout view
 
 @param type the type of popout view
 
 @return MKPopOutView instance
 */
- (id)initWithView:(UIView *)view type:(MKPopOutViewType)type;

/**
 Creates a new instance of MKPopoutView 
 
 @param view the content of the popout view
 
 @param type the type of the popout view
 
 @param graphics and instance of MKGraphicsStructures that is used when drawing the pop over view.
 
 @return MKPopOutView instance
*/
- (id)initWithView:(UIView *)view type:(MKPopOutViewType)type graphics:(MKGraphicsStructures *)graphics;

///-------------------------------------------------------
/// @name Appearance
///-------------------------------------------------------

/** The tip of the arrow position on the x-axis. */
@property (nonatomic, assign) CGFloat arrowPosition;

/** 
 Set `YES` to allow the pop over view to resize itself during a rotation. 
 Default is `NO`.
*/
@property (nonatomic, assign) BOOL autoResizeOnRotation;

///--------------------------------------------------------
/// @name Types
///--------------------------------------------------------

/** The type of popout view used */
@property (nonatomic, assign, readonly) MKPopOutViewType type;

/** 
 Reference to an MKBarButton that the pop over view will appear from.
 This property should not need to be set directly.
*/
@property (nonatomic, retain) MKBarButtonItem *button;

///--------------------------------------------------------
/// @name Deprecations
///--------------------------------------------------------

/** The tint color of the popout view. Default is black. */
@property (nonatomic, assign) CGColorRef tintColor MK_DEPRECATED_0_9;

@end

static const CGFloat kPopOutViewWidth = 300.0;

NSString *MKPopOutViewShouldRemoveNotification MK_VISIBLE_ATTRIBUTE;
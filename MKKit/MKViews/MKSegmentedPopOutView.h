//
//  MKSegmentedPopOutView.h
//  MKKit
//
//  Created by Matthew King on 12/31/11.
//  Copyright (c) 2011-2012 Matt King. All rights reserved.
//

#import "MKPopOutView.h"
#import <MKKit/MKKit/MKControls/MKControlDelegate.h>

typedef enum {
    MKSegmentRight,
    MKSegmentMid,
    MKSegmentLeft,
} MKSegmentPosition;

typedef struct {
    MKSegmentPosition pos;
    CFStringRef text;
    CGRect rect;
    int idnumber;
} MKSegment;

/**----------------------------------------------------------------------------------
 *Overview*
 
 MKSegementedPouOutView is a special subclass of MKPopOutView.  Instance create a popout
 bubble that mimics Apples UIMenuView except for you can control the colors and button
 titles. 
 
 *Usage*
 
 When creating an instance of MKSegementedPopOutView you need to provide a Array of button
 titles, and an instance of MKGraphicsStructures to provide the colors. The MKSegementedPopOutView
 will automatically adjust its segements to fit the number of titles provided. 
 
 @warning *Note* There is no limit on the number of titles instances will accept. You should
 limit it to two or three titles to make sure there is room for all the titles to be displayed.
 
 *Observing Touches*
 
 Use the addTarget:selector instance method to add listeners to MKSegementedPopOutView instances.
 When a touch occours on one of the buttons the selector passed for each target is called. Instance
 will also send its instance as an obeject of the selector. The selector should use the format:
 
        - (void)mySelector:(id)sender
 
 *Graphics*
 
 Instance support the use of MKGraphicsStructures. The following graphic properties are looked for:
 
 * fillColor : `defalut black`
 * touchedColor : `default blue`
 * useLinerShine : `default YES`
 
 *Listeners*
 
 Instance listen for the `MKPopOverViewShouldRemoveNotification` to remove itself from the superview.
-----------------------------------------------------------------------------------*/

@interface MKSegmentedPopOutView : MKPopOutView {
@public
    NSArray *mItems;
    NSInteger mSelectedIndex;
@private
    NSMutableSet *mTargets;
}

///--------------------------------
/// @name Creating
///--------------------------------

/**
 Creates an instance of MKSegmentedPopOverView
 
 @param items an array of NSString that will be used for segment titles
 
 @param graphics an instance of MKGraphicsStructures that should be used when
 drawing the view.
 
 @return MKSegmentedPopOverView instance.
*/
- (id)initWithItems:(NSArray *)items type:(MKPopOutViewType)type graphics:(MKGraphicsStructures *)graphics;

///--------------------------------
/// @name Observing Actions
///--------------------------------

/**
 Addeds an class instance to as a target to send messages to when a segment is touched.
 Selectors should be in the format
 
        - (void)mySelector:(id)sender
 
 @param target the class that will receive messages
 
 @param selector the selector to call when a segment is touched.
*/
- (void)addTarget:(id)target selector:(SEL)selector;

/** The index of the segment that was selected. Defaut is `-1`, no selection */
@property (nonatomic, readonly) NSInteger selectedIndex;

@end

/**---------------------------------------------------------------------
 MKSegmentView provides the view for an MKSegmentedPopOutView. This Class
 should not be used directly.
----------------------------------------------------------------------*/

@interface MKSegmentView : MKView {
    MKSegmentedPopOutView *mParent;
    MKSegment mSegment;
    BOOL mSelected;
}

///-----------------------------------
/// @name Creating
///-----------------------------------

/**
 Creates an instance of MKSegmentView
 
 @param segment the Segment to draw
 
 @param parent the MKSegmentedPopOut view instance that the segement is being
 drawn for.
 
 @return MKSegmentView instance
*/
- (id)initWithSegment:(MKSegment)segment parent:(MKSegmentedPopOutView *)parent;

@end

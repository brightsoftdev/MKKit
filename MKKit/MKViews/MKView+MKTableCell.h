//
//  MKView+MKTableCell.h
//  MKKit
//
//  Created by Matthew King on 1/22/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKView.h"

@class MKTableCell;

@interface MKView (MKTableCell)

///-----------------------------------
/// @name Creating
///-----------------------------------

/**
 Creates an instace of MKView for the given table cell.
 
 @param cell the cell the view will be placed on.
 
 @return MKView instance
 */
- (id)initWithCell:(MKTableCell *)cell;

///-----------------------------------
/// @name Adding Elements
///-----------------------------------

/**
 Adds a Primary Element to the cell. The primary element 
 appears on the left side of the cell.
 
 @param element the view that will be added to the cell.
 */
- (void)addPrimaryElement:(UIView *)element;

/**
 Adds a Secondary Element to the cell. The secondary element 
 appears on the right side of the cell.
 
 @param element the view that will be added to the cell.
 */
- (void)addSecondaryElement:(UIView *)element;

/**
 Adds a Icon Element to the cell. The icon element 
 appears on the left side of the cell.
 
 @param element the view that will be added to the cell.
 */
- (void)addIconElement:(UIView *)element;

/**
 Adds a view under the primary and seconday views. The primay and secondary
 views adjust to fit the new element. If the cell has an icon view assigned, 
 the detail element is moved to right to fit the icon.
 
 @param element the view that will be added to the cell.
 */
- (void)addDetailElement:(UIView *)element;

///-----------------------------------
/// @name Deprecations
///-----------------------------------

/** *DEPRECATED METHOD* use - [(void) UIView (MKMetrics) layoutForMetrics:] instead. */
- (void)layoutCell MK_DEPRECATED_1_0;

/** *DEPRECATED METHOD* */
- (void)addPrimaryElement:(UIView *)element inRect:(CGRect)rect MK_DEPRECATED_1_0;

/** *DEPRECATED METHOD* */ 
- (void)addSecondaryElement:(UIView *)element inRect:(CGRect)rect MK_DEPRECATED_1_0;

/** *DEPRECATED PROPERTY* */
@property (nonatomic, assign) BOOL pinnedPrimaryElement MK_DEPRECATED_1_0;

/** *DEPRECATED PROPERTY* */
@property (nonatomic, assign) BOOL pinnedSecondaryElement MK_DEPRECATED_1_0;



@end

static const CGFloat kCellIconRectX                 = 10.0;
static const CGFloat kCellIconRectWidth             = 30.0;

static const CGFloat kCellPrimaryElementX           = 7.0;
static const CGFloat kCellPrimaryElementWidth       = 294.0;

static const CGFloat kCellSecondaryElementX         = 115.0;
//static const CGFloat kCellSecondaryElementY         = 7.0;
static const CGFloat kCellSecondaryElementWidth     = 191.0;

static const CGFloat kCellDetailElementX            = 7.0;
static const CGFloat kCellDetailElementY            = 29.0;
static const CGFloat kCellDetailElementWidth        = 294.0;
static const CGFloat kCellDetailElementHeight       = 12.0;

static const CGFloat kCellLeftMarginPadding         = 7.0;
static const CGFloat kCellRightMarginPadding        = 10.0;
static const CGFloat kCellElementStandardTopPadding = 7.0;
static const CGFloat kCellElementStandardHeight     = 30.0;
static const CGFloat kCellIconPadding               = 51.0;
static const CGFloat kCellSecondaryElementPadding   = 5.0;

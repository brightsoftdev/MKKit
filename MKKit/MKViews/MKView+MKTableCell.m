//
//  MKView+MKTableCell.m
//  MKKit
//
//  Created by Matthew King on 1/22/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKView+MKTableCell.h"

#import <MKKit/MKKit/MKTableCells/MKTableCell.h>

@interface MKView ()

- (CGRect)iconRect;
- (CGRect)primaryRect;
- (CGRect)secondaryRect;

@end

@implementation MKView (MKTableCell)

@dynamic pinnedSecondaryElement, pinnedPrimaryElement;

#pragma mark - Initalizer

- (id)initWithCell:(MKTableCell *)cell {
    self = [super initWithFrame:cell.contentView.frame];
    if (self) {
        self.backgroundColor = CLEAR;
        self.opaque = NO;
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        self.cell = [cell retain];
                
        mShouldRemoveView = NO;
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [self layoutForMetrics:metricsForCurrentOrientation()];
}

- (void)layoutForMetrics:(MKViewMetrics)metrics {
    UIView *primaryElement = [self viewWithTag:kPrimaryViewTag];
    UIView *secondaryElement = [self viewWithTag:kSecondaryViewTag];
    UIView *iconElement = [self viewWithTag:kIconViewTag];
    UIView *detailElement = [self viewWithTag:kDetailViewTag];
    
    MKMetrics *cellMetrics = [MKMetrics metricsForView:self];
    [cellMetrics beginLayout];
    
    if (iconElement) {
        if (MK_DEVICE_IS_IPHONE) {
            [iconElement setRect:[self iconRect] forMetrics:MKMetricsPortrait];
            [iconElement setRect:[self iconRect] forMetrics:MKMetricsLandscape];
        }
        else if (MK_DEVICE_IS_IPAD) {
            [iconElement setRect:[self iconRect] forMetrics:MKMetricsPortraitIPad];
            [iconElement setRect:[self iconRect] forMetrics:MKMetricsLandscapeIPad];
        }
        
        [cellMetrics layoutSubview:iconElement forMetrics:metrics];
        [cellMetrics horizontallyCenterView:iconElement];
    }
    
    if (detailElement) {
        
    }
    
    if (secondaryElement) {
        if (MK_DEVICE_IS_IPHONE) {
            [secondaryElement setRect:[self secondaryRect] forMetrics:MKMetricsPortrait];
            [secondaryElement setRect:[self secondaryRect] forMetrics:MKMetricsLandscape];
        }
        else if (MK_DEVICE_IS_IPAD) {
            [secondaryElement setRect:[self secondaryRect] forMetrics:MKMetricsPortraitIPad];
            [secondaryElement setRect:[self secondaryRect] forMetrics:MKMetricsLandscapeIPad];
        }
        [cellMetrics layoutSubview:secondaryElement forMetrics:metrics];
    }
    
    if (primaryElement) {
        if (MK_DEVICE_IS_IPHONE) {
            [primaryElement setRect:[self primaryRect] forMetrics:MKMetricsPortrait];
            [primaryElement setRect:[self primaryRect] forMetrics:MKMetricsLandscape];
        }
        else if (MK_DEVICE_IS_IPAD) {
            [primaryElement setRect:[self primaryRect] forMetrics:MKMetricsPortraitIPad];
            [primaryElement setRect:[self primaryRect] forMetrics:MKMetricsLandscapeIPad];
        }
        
        [cellMetrics layoutSubview:primaryElement forMetrics:metrics];
    }
    
    [cellMetrics endLayout];
    
    [self.cell layoutForMetrics:metrics];
}

#pragma mark - Adding Elements

- (void)addPrimaryElement:(UIView *)element {
    element.tag = kPrimaryViewTag;
    [self addSubview:element];
}

- (void)addSecondaryElement:(UIView *)element {
    element.tag = kSecondaryViewTag;
    
    [self addSubview:element];
}

- (void)addIconElement:(UIView *)element {
    element.tag = kIconViewTag;
    [self addSubview:element];
}

- (void)addDetailElement:(UIView *)element {
    element.tag = kDetailViewTag;
    
    [self addSubview:element];
}

#pragma mark - Rect Helpers

- (CGRect)iconRect {
    return CGRectMake(kCellLeftMarginPadding, kCellElementStandardTopPadding, kCellIconRectWidth, kCellElementStandardHeight);
}

- (CGRect)primaryRect {
    UIView *iconElement = [self viewWithTag:kIconViewTag];
    UIView *secondaryElement = [self viewWithTag:kSecondaryViewTag];
    
    float cellWidth = self.cell.contentView.frame.size.width;
    
    float primaryX = kCellLeftMarginPadding;
    float primaryY = kCellElementStandardTopPadding;
    float primaryHeight = kCellElementStandardHeight;
    float primaryWidth = 0.0;
    float secondaryWidth = 0.0;
    
    if (iconElement) {
        primaryX = kCellIconPadding;
    }
    
    if (secondaryElement) {
        secondaryWidth = (secondaryElement.frame.size.width + 5);
    }
    
    primaryWidth = (cellWidth - primaryX - kCellRightMarginPadding - secondaryWidth);

    return CGRectMake(primaryX, primaryY, primaryWidth, primaryHeight);
}

- (CGRect)secondaryRect {
    float cellWidth = self.cell.contentView.frame.size.width;
    float secondayWidth = (cellWidth - kCellSecondaryElementX - kCellRightMarginPadding);
    
    return CGRectMake(kCellSecondaryElementX, kCellElementStandardTopPadding, secondayWidth, kCellElementStandardHeight);
}

#pragma mark - Deprecations

- (void)layoutCell {
    /// DEPRECATED
}

- (void)addPrimaryElement:(UIView *)element inRect:(CGRect)rect {
    /// DEPRECATED
}

- (void)addSecondaryElement:(UIView *)element inRect:(CGRect)rect {
    /// DEPRECATED
}

@end

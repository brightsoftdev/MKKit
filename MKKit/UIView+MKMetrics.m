//
//  UIView+MKMetrics.m
//  MKKit
//
//  Created by Matthew King on 1/15/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "UIView+MKMetrics.h"

static const char *PortraitXTag         = "PortraitXTag";
static const char *PortraitYTag         = "PortraitYTag";
static const char *PortraitWidthTag     = "PortraitWidthTag";
static const char *PortraitHeightTag    = "PortraitHightTag";

static const char *LandscapeXTag        = "LandscapeXTag";
static const char *LandscapeYTag        = "LandscapeYTag";
static const char *LandscapeWidthTag    = "LandscapeWidthTag";
static const char *LandscapeHeightTag   = "LandscapeHeightTag";

@implementation UIView (MKMetrics)

@dynamic portraitRect, landscapeRect;

#pragma mark - Layout

- (void)layoutForMetrics:(MKViewMetrics)metrics {
    ///Method for subclasses
}

#pragma mark - Size Settings

- (void)setSize:(CGSize)size forMetrics:(MKViewMetrics)metrics {
    CGRect rect = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
    [self setRect:rect forMetrics:metrics];
}

- (void)setLocation:(CGPoint)location forMetrics:(MKViewMetrics)metrics {
    CGRect rect = CGRectMake(location.x, location.y, self.frame.size.width, self.frame.size.height);
    [self setRect:rect forMetrics:metrics];
}

- (void)setRect:(CGRect)rect forMetrics:(MKViewMetrics)metrics {
    NSNumber *x = [NSNumber numberWithFloat:rect.origin.x];
    NSNumber *y = [NSNumber numberWithFloat:rect.origin.y];
    NSNumber *width = [NSNumber numberWithFloat:rect.size.width];
    NSNumber *height = [NSNumber numberWithFloat:rect.size.height];
    
    switch (metrics) {
        case MKMetricsPortrait: {
            objc_setAssociatedObject(self, PortraitXTag, x, OBJC_ASSOCIATION_RETAIN);
            objc_setAssociatedObject(self, PortraitYTag, y, OBJC_ASSOCIATION_RETAIN);
            objc_setAssociatedObject(self, PortraitWidthTag, width, OBJC_ASSOCIATION_RETAIN);
            objc_setAssociatedObject(self, PortraitHeightTag, height, OBJC_ASSOCIATION_RETAIN);
        } break;
        case MKMetricsLandscape: {
            objc_setAssociatedObject(self, LandscapeXTag, x, OBJC_ASSOCIATION_RETAIN);
            objc_setAssociatedObject(self, LandscapeYTag, y, OBJC_ASSOCIATION_RETAIN);
            objc_setAssociatedObject(self, LandscapeWidthTag, width, OBJC_ASSOCIATION_RETAIN);
            objc_setAssociatedObject(self, LandscapeHeightTag, height, OBJC_ASSOCIATION_RETAIN);
        } break;
        case MKMetricsPortraitIPad: {
            objc_setAssociatedObject(self, PortraitXTag, x, OBJC_ASSOCIATION_RETAIN);
            objc_setAssociatedObject(self, PortraitYTag, y, OBJC_ASSOCIATION_RETAIN);
            objc_setAssociatedObject(self, PortraitWidthTag, width, OBJC_ASSOCIATION_RETAIN);
            objc_setAssociatedObject(self, PortraitHeightTag, height, OBJC_ASSOCIATION_RETAIN);
        } break;
        case MKMetricsLandscapeIPad: {
            objc_setAssociatedObject(self, LandscapeXTag, x, OBJC_ASSOCIATION_RETAIN);
            objc_setAssociatedObject(self, LandscapeYTag, y, OBJC_ASSOCIATION_RETAIN);
            objc_setAssociatedObject(self, LandscapeWidthTag, width, OBJC_ASSOCIATION_RETAIN);
            objc_setAssociatedObject(self, LandscapeHeightTag, height, OBJC_ASSOCIATION_RETAIN);
        } break;
        default: break;
    }
}


#pragma mark - Accessor Methods
#pragma mark Getters

- (CGRect)portraitRect {
    CGFloat x = [(NSNumber *)objc_getAssociatedObject(self, PortraitXTag) floatValue];
    CGFloat y = [(NSNumber *)objc_getAssociatedObject(self, PortraitYTag) floatValue];
    CGFloat width = [(NSNumber *)objc_getAssociatedObject(self, PortraitWidthTag) floatValue];
    CGFloat height = [(NSNumber *)objc_getAssociatedObject(self, PortraitHeightTag) floatValue];
    
    return CGRectMake(x, y, width, height);
}

- (CGRect)landscapeRect {
    CGFloat x = [(NSNumber *)objc_getAssociatedObject(self, LandscapeXTag) floatValue];
    CGFloat y = [(NSNumber *)objc_getAssociatedObject(self, LandscapeYTag) floatValue];
    CGFloat width = [(NSNumber *)objc_getAssociatedObject(self, LandscapeWidthTag) floatValue];
    CGFloat height = [(NSNumber *)objc_getAssociatedObject(self, LandscapeHeightTag) floatValue];
    
    return CGRectMake(x, y, width, height);
}

#pragma mark - Memory

- (void)clearMetrics {
    objc_removeAssociatedObjects(self);
}

@end

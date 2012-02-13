//
//  MKMetrics.m
//  MKKit
//
//  Created by Matthew King on 1/15/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKMetrics.h"

#import "UIView+MKMetrics.h"

@interface MKMetrics () 

- (id)initWithView:(UIView *)view;

@end

@implementation MKMetrics

@synthesize view;

#pragma mark - Creation

+ (id)metricsForView:(UIView *)view {
    return [[[[self class] alloc] initWithView:view] autorelease];
}

- (id)initWithView:(UIView *)_view {
    self = [super init];
    if (self) {
        self.view = _view;
    }
    return self;
}

#pragma mark - Memory

- (void)dealloc {
    self.view = nil;
    
    [super dealloc];
}

#pragma mark - Layout

- (void)beginLayout {
    
}

- (void)endLayout {
    for (UIView *aView in self.view.subviews) {
        [aView clearMetrics];
    }
}

- (void)layoutSubview:(UIView *)subview forMetrics:(MKViewMetrics)metrics {
    CGRect rect = subview.frame;
    
    switch (metrics) {
        case MKMetricsPortrait: rect = subview.portraitRect; break;
        case MKMetricsLandscape: rect = subview.landscapeRect; break;
        default: break;
    }
    
    subview.frame = rect;
}

#pragma mark Layout Options

- (void)horizontallyCenterView:(UIView *)subview {
    float remainingHeight = (self.view.frame.size.height - subview.frame.size.height);
    float topSpace = (remainingHeight / 2.0);
    
    subview.frame = CGRectMake(subview.frame.origin.x, topSpace, subview.frame.size.width, subview.frame.size.height);
}

@end

#pragma mark - Helper Functions
#pragma mark Widths

CGFloat widthForOrientation(UIInterfaceOrientation orientation) {
    return widthForMetrics(metricsForOrientation(orientation));
}

CGFloat widthForMetrics(MKViewMetrics metrics) {
    CGFloat width = 320.0;
    
    switch (metrics) {
        case MKMetricsPortrait: {
            if (MK_DEVICE_IS_IPHONE) {
                width = 320.0;
            }
            else {
                width = 768.0;
            }
        } break;
            
        case MKMetricsLandscape: {
            if (MK_DEVICE_IS_IPHONE) {
                width = 480.0;
            }
            else {
                width = 1024.0;
            }
        } break;
        default: break;
    }
    
    return width;
}

#pragma mark Heights

CGFloat heightForMetric(MKViewMetrics metrics) {
    BOOL hiddenStatusBar = [[UIApplication sharedApplication] isStatusBarHidden];
    CGFloat height = 460.0;
    
    switch (metrics) {
        case MKMetricsPortrait: {
            if (MK_DEVICE_IS_IPHONE) {
                height = 460.0;
            }
            else {
                height = 1004.0;
            }
        } break;
        case MKMetricsLandscape: {
            if (MK_DEVICE_IS_IPHONE) {
                height = 300.0;
            }
            else {
                height = 748.0;
            }
        } break;
        default:
            break;
    }
    
    if (hiddenStatusBar) {
        height = (height + 20.0);
    }
    return height;
}

#pragma mark Metrics

MKViewMetrics metricsForCurrentOrientation() {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    MKViewMetrics viewMetrics = metricsForOrientation(orientation);
    
    return viewMetrics;
}

MKViewMetrics metricsForOrientation(UIInterfaceOrientation orientation) {
    MKViewMetrics viewMetrics;
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait: viewMetrics = MKMetricsPortrait; break;
        case UIInterfaceOrientationPortraitUpsideDown: viewMetrics = MKMetricsPortrait; break;
        case UIInterfaceOrientationLandscapeLeft: viewMetrics = MKMetricsLandscape; break;
        case UIInterfaceOrientationLandscapeRight: viewMetrics = MKMetricsLandscape; break;
        default: break;
    }
    
    return viewMetrics;
}
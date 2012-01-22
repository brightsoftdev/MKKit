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
        case MKMetricsPortraitIPad: rect = subview.portraitRect; break;
        case MKMetricsLandscapeIPad: rect = subview.landscapeRect; break;
        default: break;
    }
    
    subview.frame = rect;
}

@end

#pragma mark - Helper Functions

CGFloat widthForOrientation(UIInterfaceOrientation orientation) {
    CGFloat width = 320.0;
    
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        width = 320.0;
        if (MK_DEVICE_IS_IPAD) {
            width = 768.0;
        }
    }
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        width = 480.0;
        if (MK_DEVICE_IS_IPAD) {
            width = 1024.0;
        }
    }
    
    return width;
}

CGFloat widthForMetrics(MKViewMetrics metrics) {
    CGFloat width = 320.0;
    
    switch (metrics) {
        case MKMetricsPortrait: width = 320.0; break;
        case MKMetricsLandscape: width = 480.0; break;
        case MKMetricsPortraitIPad: width = 768.0; break;
        case MKMetricsLandscapeIPad:width = 1024.0; break;
        default: break;
    }
    
    return width;
}

MKViewMetrics metricsForCurrentOrientation() {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    MKViewMetrics viewMetrics;
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait: viewMetrics = MKMetricsPortrait; break;
        case UIInterfaceOrientationPortraitUpsideDown: viewMetrics = MKMetricsPortrait; break;
        case UIInterfaceOrientationLandscapeLeft: viewMetrics = MKMetricsLandscape; break;
        case UIInterfaceOrientationLandscapeRight: viewMetrics = MKMetricsLandscape; break;
        default: break;
    }
    
    if (MK_DEVICE_IS_IPAD) {
        if (viewMetrics == MKMetricsPortrait) {
            viewMetrics = MKMetricsPortraitIPad;
        }
        if (viewMetrics == MKMetricsLandscape) {
            viewMetrics = MKMetricsLandscapeIPad;
        }
    }
    
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
    
    if (MK_DEVICE_IS_IPAD) {
        if (viewMetrics == MKMetricsPortrait) {
            viewMetrics = MKMetricsPortraitIPad;
        }
        if (viewMetrics == MKMetricsLandscape) {
            viewMetrics = MKMetricsLandscapeIPad;
        }
    }

    return viewMetrics;
}
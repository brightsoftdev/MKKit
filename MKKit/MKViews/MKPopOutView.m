//
//  MKPopOutView.m
//  MKKit
//
//  Created by Matthew King on 8/2/11.
//  Copyright 2010-2011 Matt King. All rights reserved.
//

#import "MKPopOutView.h"

#import "MKView+Internal.h"
#import "MKPopoutView+MKTableCell.m"
#import "MKPopOutView+MKBarButtonItem.h"

@implementation MKPopOutView

#pragma mark - Creation

@synthesize type=mType, arrowPosition=mArrowPosition, tintColor, button, autoResizeOnRotation;

- (id)initWithView:(UIView *)view type:(MKPopOutViewType)type {
    self = [super initWithFrame:CGRectMake(0.0, 0.0, (kPopOutViewWidth + 5.0), (view.frame.size.height + 30.0))];
    if (self) {
        self = [self initWithView:view type:type graphics:nil];
    }
    return self;
}

- (id)initWithView:(UIView *)view type:(MKPopOutViewType)type graphics:(MKGraphicsStructures *)graphics {
    self = [super initWithFrame:CGRectMake(0.0, 0.0, (kPopOutViewWidth + 5.0), (view.frame.size.height + 30.0))];
    if (self) {
        mView = [view retain];
        mType = type;
        
        self.alpha = 0.0;
        self.backgroundColor = CLEAR;
        self.opaque = YES;
        self.tag = kMKPopOutViewTag;
        
        if (!graphics) {
            self.graphicsStructure = [self defaultGraphics];
        }
        else {
            self.graphicsStructure = graphics;
        }
        
        if (type == MKPopOutBelow) {
            view.frame = CGRectMake(0.0, 30.0, view.frame.size.width, view.frame.size.height);
        }
        
        [self addSubview:mView];
        [mView release];
        
        MKPopOutViewShouldRemoveNotification = @"MKPopOutViewShouldRemoveNotification";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeView) name:MKPopOutViewShouldRemoveNotification object:nil];
    }
    return self;
}

#pragma mark - Memory

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKPopOutViewShouldRemoveNotification object:nil];
    
    [super dealloc];
}

#pragma mark - Layout

- (void)layoutForMetrics:(MKViewMetrics)_metrics {
    if (autoResizeOnRotation) {
        if (MK_DEVICE_IS_IPHONE) {
            [self setSize:CGSizeMake(300.0, self.frame.size.height) forMetrics:MKMetricsPortrait];
            [self setSize:CGSizeMake(460.0, self.frame.size.height) forMetrics:MKMetricsLandscape];
        }
        if (MK_DEVICE_IS_IPAD) {
            [self setSize:CGSizeMake(300.0, self.frame.size.height) forMetrics:MKMetricsPortraitIPad];
            [self setSize:CGSizeMake(460.0, self.frame.size.height) forMetrics:MKMetricsLandscapeIPad];
        }
        
        MKMetrics *metrics = [MKMetrics metricsForView:self];
        [metrics beginLayout];
        [metrics layoutSubview:self forMetrics:_metrics];
        [metrics endLayout];
        
        [self setNeedsDisplayInRect:self.frame];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    
    CGColorRef fillColor = self.graphicsStructure.fillColor.CGColor;
    
    CGRect drawRect = rectForType(mAutoType, rect);
    CGRect innerRect = CGRectInset(drawRect, 1.0, 1.0);
    
    mView.frame = CGRectInset(innerRect, 3.0, 3.0);
    
    CGContextSetShadow(context, CGSizeMake(0.0, 3.0), 3.0);
    
    CGContextBeginTransparencyLayer(context, NULL);
    drawPointerForType(context, mAutoType, fillColor, self.arrowPosition, drawRect);
    drawBackgroundForRect(context, drawRect, innerRect, self.graphicsStructure);
    CGContextEndTransparencyLayer(context);
}

#pragma mark Helpers

CGRect rectForType(MKPopOutViewType type, CGRect rect) {
    CGRect drawRect = CGRectZero;
    
    switch (type) {
        case MKPopOutBelow:
            drawRect = CGRectMake(5.0, 20.0, (rect.size.width - 5.0), (rect.size.height - 30.0));
            break;
        case MKPopOutAbove:
            drawRect = CGRectMake(5.0, 5.0, (rect.size.width - 5.0), (rect.size.height - 30.0));
        default:
            break;
    }
    
    return drawRect;
}

void drawPointerForType(CGContextRef context, MKPopOutViewType type, CGColorRef fill, CGFloat position, CGRect drawRect) {
    if (type == MKPopOutBelow) {
        CGRect pointerRect = CGRectZero;
        
        if (position != 0.0) {
            pointerRect = CGRectMake((position - 17.5), (CGRectGetMinY(drawRect) - 20.0), 35.0, 20.0);
        }
        else {
            pointerRect = CGRectMake((CGRectGetMaxX(drawRect) - 70.0), (CGRectGetMinY(drawRect) - 20.0), 35.0, 20.0);
        }
        
        CGMutablePathRef pointerPath = createPathForUpPointer(pointerRect);
        
        CGContextSetFillColorWithColor(context, fill);
        CGContextAddPath(context, pointerPath);
        CGContextFillPath(context);
        
        CFRelease(pointerPath);
    }
    else if (type == MKPopOutAbove) {
        CGRect pointerRect = CGRectZero;
        
        if (position != 0.0) {
            pointerRect = CGRectMake((position - 30.0), CGRectGetMaxY(drawRect), 35.0, 20.0);
        }
        else {
            pointerRect = CGRectMake((CGRectGetMaxX(drawRect) - 70.0), CGRectGetMaxY(drawRect), 35.0, 20.0);
        }
        
        CGMutablePathRef pointerPath = createPathForDownPointer(pointerRect);
        
        CGContextSetFillColorWithColor(context, fill);
        CGContextAddPath(context, pointerPath);
        CGContextFillPath(context);
        
        CFRelease(pointerPath);
    }
}

void drawBackgroundForRect(CGContextRef context, CGRect drawRect, CGRect innerRect, MKGraphicsStructures *graphics) {
    CGColorRef fillColor = graphics.fillColor.CGColor;
    
    CGMutablePathRef path = createRoundedRectForRect(drawRect, 10.0);
    CGMutablePathRef innerPath = createRoundedRectForRect(innerRect, 10.0);
    
    CGContextSetFillColorWithColor(context, fillColor);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, innerPath);
    CGContextClip(context);
    if (graphics.useLinerShine) {
        drawGlossAndLinearGradient(context, innerRect, fillColor, fillColor);
    }
    else {
        drawLinearGradient(context, innerRect, fillColor, fillColor);
    }
    CGContextRestoreGState(context);
    
    CFRelease(path);
    CFRelease(innerPath);
}

#pragma mark - Accessor Methods

- (void)setArrowPosition:(CGFloat)position {
    mArrowPosition = position;
    [self setNeedsDisplay];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([touch tapCount] == 1) {
        [self removeView];
    }
}

@end

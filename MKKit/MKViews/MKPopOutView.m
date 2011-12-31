//
//  MKPopOutView.m
//  MKKit
//
//  Created by Matthew King on 8/2/11.
//  Copyright 2010-2011 Matt King. All rights reserved.
//

#import "MKPopOutView.h"

#import "MKView+Internal.h"

@implementation MKPopOutView

#pragma mark - Creation

@synthesize type=mType, arrowPosition=mArrowPosition, tintColor;

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

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    
    CGRect drawRect = CGRectZero;
    CGColorRef fillColor = self.graphicsStructure.fillColor.CGColor;
    
    switch (mAutoType) {
        case MKPopOutBelow:
            drawRect = CGRectInset(rect, 5.0, 20.0);
            break;
        case MKPopOutAbove:
            drawRect = CGRectMake(5.0, 5.0, (rect.size.width - 5.0), (rect.size.height - 30.0));
        default:
            break;
    }
    
    CGRect innerRect = CGRectInset(drawRect, 1.0, 1.0);
    
    CGMutablePathRef path = createRoundedRectForRect(drawRect, 20.0);
    CGMutablePathRef innerPath = createRoundedRectForRect(innerRect, 20.0);
    
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0, 3.0), 3.0, MK_SHADOW_COLOR);
    CGContextSetFillColorWithColor(context, fillColor);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGContextSaveGState(context);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, innerPath);
    CGContextClip(context);
    if (self.graphicsStructure.useLinerShine) {
        drawGlossAndLinearGradient(context, innerRect, fillColor, fillColor);
    }
    else {
        drawLinearGradient(context, innerRect, fillColor, fillColor);
    }
    CGContextRestoreGState(context);
    
    if (mAutoType == MKPopOutBelow) {
        CGRect pointerRect = CGRectZero;
        
        if (mArrowPosition != 0.0) {
            pointerRect = CGRectMake((self.arrowPosition - 30.0), (CGRectGetMinY(drawRect) - 20.0), 35.0, 20.0);
        }
        else {
            pointerRect = CGRectMake((CGRectGetMaxX(drawRect) - 70.0), (CGRectGetMinY(drawRect) - 20.0), 35.0, 20.0);
        }
        
        CGMutablePathRef pointerPath = createPathForUpPointer(pointerRect);
        
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, fillColor);
        CGContextAddPath(context, pointerPath);
        CGContextFillPath(context);
        CGContextSaveGState(context);
        
        CFRelease(pointerPath);
    }
    else if (mAutoType == MKPopOutAbove) {
        CGRect pointerRect = CGRectMake((CGRectGetMaxX(drawRect) - 70.0), CGRectGetMaxY(drawRect), 35.0, 20.0);
        CGMutablePathRef pointerPath = createPathForDownPointer(pointerRect);
        
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, fillColor);
        CGContextAddPath(context, pointerPath);
        CGContextFillPath(context);
        CGContextSaveGState(context);
        
        CFRelease(pointerPath);
    }
    
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

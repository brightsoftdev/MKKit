//
//  MKBarButtonItem.m
//  MKKit
//
//  Created by Matthew King on 6/18/11.
//  Copyright 2011 Matt King. All rights reserved.
//

#import "MKBarButtonItem.h"

#import <MKKit/MKKit/MKImage.h>

void drawButtonWithGraphics(CGContextRef context, CGRect rect, MKGraphicsStructures *graphics, MKBarButtonItemType buttonType, MKControlState state);

@implementation MKBarButtonItem

@dynamic type;

#pragma mark - Initalizer

- (id)initWithType:(MKBarButtonItemType)type {
    //////  DEPRECIATED v0.9 /////
    return nil;
}

- (id)initWithIcon:(MKImage *)icon {
    self = [super init];
    if (self) {
        [self setUpControl];
        self.frame = CGRectMake(0.0, 0.0, icon.size.width, icon.size.height);
        
        mType = MKBarButtonItemIcon;
        
        MKBarButtonItemFlags.requiresDrawing = NO;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
        imageView.frame = self.frame;
        
        [self addSubview:imageView];
        [imageView release];
    }
    
    return self;
}

- (id)initWithType:(MKBarButtonItemType)type graphics:(MKGraphicsStructures *)graphics {
    self = [super initWithGraphics:graphics]; 
    if (self) {
        [self setUpControl];
        mType = type;
        
        MKBarButtonItemFlags.requiresDrawing = YES;
        
        if (type == MKBarButtonItemBackArrow || type == MKBarButtonItemForwardArrow) {
            self.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
        }
    }
    return self;
}

- (void)setUpControl {
    self.opaque = NO;
    self.backgroundColor = CLEAR;
    self.controlState = MKControlStateNormal;
}

#pragma mark - Memory

- (void)dealloc {
    [super dealloc];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    if (MKBarButtonItemFlags.requiresDrawing) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetAllowsAntialiasing(context, YES);
        
        drawButtonWithGraphics(context, self.bounds, mGraphics, self.type, self.controlState);
    }
}


void drawButtonWithGraphics(CGContextRef context, CGRect rect, MKGraphicsStructures *graphics, MKBarButtonItemType buttonType, MKControlState state) {
    CGColorRef top = topColorForControlState(state, graphics);
    CGColorRef bottom = bottomColorForControlState(state, graphics);
    CGColorRef shadowColor = [UIColor blackColor].CGColor;
    
    CGMutablePathRef buttonPath = nil;

    CGRect arrowButtonRect = CGRectInset(rect, 2.0, 2.0);
    
    switch (buttonType) {
        case MKBarButtonItemBackArrow:
            buttonPath = createPathForLeftArrow(arrowButtonRect);
            break;
        case MKBarButtonItemForwardArrow:
            buttonPath = createPathForRightArrow(arrowButtonRect);
            break;
        default:
            break;
    }
    
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0, -1.0), 0.0, shadowColor);
    CGContextAddPath(context, buttonPath);
    CGContextClip(context);
    
    if (graphics.useLinerShine) {
        drawGlossAndLinearGradient(context, arrowButtonRect, top, bottom);
    }
    else {
        drawLinearGradient(context, arrowButtonRect, top, bottom);
    }
    
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextAddRect(context, arrowButtonRect);
    CGContextAddPath(context, buttonPath);
    CGContextEOClip(context);
    CGContextAddPath(context, buttonPath);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    CFRelease(buttonPath);
}

#pragma mark - Accessors
#pragma mark Setters

- (void)setType:(MKBarButtonItemType)_type {
    mType = _type;
}

#pragma mark Getters

- (MKBarButtonItemType)type {
    return mType;
}

@end

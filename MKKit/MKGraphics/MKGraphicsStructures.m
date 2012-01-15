//
//  MKGraphicsStructures.m
//  MKKit
//
//  Created by Matthew King on 9/18/11.
//  Copyright (c) 2010-2011 Matt King. All rights reserved.
//

#import "MKGraphicsStructures.h"

MKGraphicsBorder MKGraphicBorderMake(CGFloat width, UIColor *color) {
    MKGraphicsBorder border;
    border.width = width;
    border.color = color.CGColor;
    
    return border;
}

MKGraphicsShadow MKGraphicShadowMake(CGSize offset, CGFloat blur, UIColor *color) {
    MKGraphicsShadow shadow;
    shadow.offset = offset;
    shadow.blur = blur;
    shadow.color = color.CGColor;
    
    return shadow;
}

@implementation MKGraphicsStructures

@synthesize fillColor, useLinerShine, topColor, bottomColor, disabledColor, touchedColor;

@dynamic bordered, shadowed, border, shadow;

#pragma mark - Creation

+ (id)graphicsStructure {
    return [[[[self class] alloc] init] autorelease];
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - Memory Managment

- (void)dealloc {
    self.topColor = nil;
    self.bottomColor = nil;
    self.fillColor= nil;
    self.disabledColor = nil;
    self.touchedColor = nil;
    
    [super dealloc];
}

#pragma mark - Accessor Methods
#pragma mark Setters

- (void)setBorder:(MKGraphicsBorder)_border {
    mBordered = YES;
    mBorder = _border;
}

- (void)setShadow:(MKGraphicsShadow)_shadow {
    mShadowed = YES;
    mShadow = _shadow;
}

#pragma mark Getters

- (BOOL)bordered {
    return mBordered;
}

- (BOOL)shadowed {
    return mShadowed;
}

- (MKGraphicsBorder)border {
    return mBorder;
}

- (MKGraphicsShadow)shadow {
    return mShadow;
}


#pragma mark Deprecated v0.9

- (void)assignGradientTopColor:(UIColor *)_topColor bottomColor:(UIColor *)_bottomColor {
    
}

- (id)initWithLinearGradientTopColor:(UIColor *)_topColor bottomColor:(UIColor *)_bottomColor {
    return nil;
}

+ (id)linearGradientWithTopColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor {
    return nil;
}
@end
//
//  MKGraphicsStructures.m
//  MKKit
//
//  Created by Matthew King on 9/18/11.
//  Copyright (c) 2010-2011 Matt King. All rights reserved.
//

#import "MKGraphicsStructures.h"

@interface MKGraphicsStructures ()

- (id)initWithLinearGradientTopColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor;

@end

@implementation MKGraphicsStructures

@synthesize fillColor, useLinerShine, topColor, bottomColor, borderColor, disabledColor, touchedColor, bordered, borderWidth,
shadowed, shadowOffset, shadowBlur, shadowColor;

#pragma mark - Creation

+ (id)graphicsStructure {
    return [[[[self class] alloc] init] autorelease];
}

+ (id)linearGradientWithTopColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor {
    return [[[[self class] alloc] initWithLinearGradientTopColor:topColor bottomColor:bottomColor] autorelease];
}

- (id)init {
    self = [super init];
    if (self) {
        [self setObjectKeys];
    }
    return self;
}

- (id)initWithLinearGradientTopColor:(UIColor *)_topColor bottomColor:(UIColor *)_bottomColor {
    self = [super init];
    if (self) {
        [self setObjectKeys];
        
        self.topColor = _topColor;
        self.bottomColor = _bottomColor;
    }
    return self;
}

#pragma mark - Memory Managment

- (void)dealloc {
    self.topColor = nil;
    self.bottomColor = nil;
    self.fillColor= nil;
    self.borderColor = nil;
    self.disabledColor = nil;
    self.touchedColor = nil;
    
    [super dealloc];
}

#pragma mark - Adding Structures

- (void)assignGradientTopColor:(UIColor *)_topColor bottomColor:(UIColor *)_bottomColor {
    self.topColor = _topColor;
    self.bottomColor = _bottomColor;
}

@end
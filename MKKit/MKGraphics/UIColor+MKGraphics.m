//
//  UIColor+MKGraphics.m
//  MKKit
//
//  Created by Matthew King on 12/26/11.
//  Copyright (c) 2011 Matt King. All rights reserved.
//

#import "UIColor+MKGraphics.h"

@implementation UIColor (MKGraphics)

+ (UIColor *)colorWithHSBADictionary:(NSDictionary *)dictionary {
    float h = [[dictionary objectForKey:@"h"] floatValue];
    float s = [[dictionary objectForKey:@"s"] floatValue];
    float b = [[dictionary objectForKey:@"b"] floatValue];
    float a = [[dictionary objectForKey:@"a"] floatValue];
    
    UIColor *hsbaColor = MK_COLOR_HSB(h, s, b, a);
    return hsbaColor;
}

+ (UIColor *)colorWithRGBADictionary:(NSDictionary *)dictionary {
    float r = [[dictionary objectForKey:@"r"] floatValue];
    float g = [[dictionary objectForKey:@"g"] floatValue];
    float b = [[dictionary objectForKey:@"b"] floatValue];
    float a = [[dictionary objectForKey:@"a"] floatValue];
    
    UIColor *rgbaColor = MK_COLOR_RGB(r, g, b, a);
    return rgbaColor;
}

@end

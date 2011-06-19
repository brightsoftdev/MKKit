//
//  MKGraphics.m
//  MKKit
//
//  Created by Matthew King on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MKGraphics.h"

#pragma mark - gradients

void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0.0, 1.0};
    
    NSArray *colors = [NSArray arrayWithObjects:(id)startColor, (id)endColor, nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinX(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

void drawGlossAndLinearGradient(CGContextRef conext, CGRect rect, CGColorRef startColor, CGColorRef endColor) {
    drawLinearGradient(conext, rect, startColor, endColor);
    
    UIColor *gloss1color = MK_COLOR_RGB(255.0, 255.0, 255.0, 0.35);
    UIColor *gloss2color = MK_COLOR_RGB(255.0, 255.0, 255.0, 0.1);
    
    CGRect topHalf = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, (rect.size.height / 2.0));
    
    drawLinearGradient(conext, topHalf, gloss1color.CGColor, gloss2color.CGColor);
}

#pragma mark - Rects

CGRect rectFor1pxStroke(CGRect rect) {
    return CGRectMake(rect.origin.x + 0.5, rect.origin.y + 0.5, rect.size.width - 1, rect.size.height - 1);
}

CGMutablePathRef createRoundedRectForRect(CGRect rect, CGFloat radius) {
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect));
    
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect),CGRectGetMaxX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMinY(rect), radius);
    
    CGPathCloseSubpath(path);
    
    return path;      
}

#pragma mark - Text

void drawText(CGContextRef context, CGRect rect, CFStringRef text, CGColorRef color, CGColorRef shadowColor, CGFloat size) {
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, color);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 1.0, shadowColor);
    [(NSString *)text drawInRect:rect withFont:[UIFont fontWithName:VERDANA_BOLD_FONT size:size]];
    CGContextRestoreGState(context);
}
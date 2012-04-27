//
//  MKControl+MKTableCell.m
//  MKKit
//
//  Created by Matt King on 4/26/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKControl+MKTableCell.h"
#import  <MKKit/MKKit/MKTableCells/MKTableCell.h>

//---------------------------------------------------------------
// Constants
//---------------------------------------------------------------

static const char *TypeTagKey = "TypeTag";

//---------------------------------------------------------------
// Functions
//---------------------------------------------------------------

void drawWarningIcon(CGContextRef context, CGRect rect);
void drawAddIcon(CGContextRef context, CGRect rect);
void drawSubtractIcon(CGContextRef context, CGRect rect);

//---------------------------------------------------------------
// Implentation
//---------------------------------------------------------------

@implementation MKControl (MKTableCell)

@dynamic viewType;

//---------------------------------------------------------------
// Creation
//---------------------------------------------------------------

#pragma mark - Creation

- (id)initWithType:(int)type {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
        self.backgroundColor = CLEAR;
        self.opaque = NO;
        self.viewType = [NSNumber numberWithInt:type];
        
        if (((int)type) == MKTableCellAccessoryWarningIcon) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 5.0, 30.0, 25.0)];
            label.textAlignment = UITextAlignmentCenter;
            label.backgroundColor = CLEAR;
            label.textColor = WHITE;
            label.shadowColor = RED;
            label.shadowOffset = CGSizeMake(0.0, -1.0);
            label.font = SYSTEM_BOLD(24.0);
            label.text = @"!";
            
            [self addSubview:label];
            [label release];
        }
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
        self.backgroundColor = CLEAR;
        self.opaque = NO;
        self.viewType = [NSNumber numberWithInt:MKTableCellAccessoryNone];
        
        UIImageView *view = [[UIImageView alloc] initWithImage:image];
        view.frame = self.frame;
        [self addSubview:view];
        [view release];
    }
    return self;
}

//---------------------------------------------------------------
// Accessors
//---------------------------------------------------------------

#pragma mark - Accessors

- (void)setViewType:(id)type {
    objc_setAssociatedObject(self, TypeTagKey, type, OBJC_ASSOCIATION_ASSIGN);
}

- (id)viewType {
    return objc_getAssociatedObject(self, TypeTagKey);
}

//---------------------------------------------------------------
// Drawing
//---------------------------------------------------------------

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    
    if ([(NSNumber *)self.viewType intValue] == MKTableCellAccessoryWarningIcon) {
        drawWarningIcon(context, rect);
    }
    if ([(NSNumber *)self.viewType intValue] == MKTableCellAccessoryAdd) {
        drawAddIcon(context, rect);
    }
    if ([(NSNumber *)self.viewType intValue] == MKTableCellAccessorySubtract) {
        drawSubtractIcon(context, rect);
    }
}

//---------------------------------------------------------------
// Warning Icon
//---------------------------------------------------------------

#pragma mark Warning Icon

void drawWarningIcon(CGContextRef context, CGRect rect) {
    CGColorRef redColor = RED.CGColor;
    
    CGPoint p1 = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint p2 = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGPoint p3 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, p1.x, p1.y);
    CGPathAddLineToPoint(path, NULL, p2.x, p2.y);
    CGPathAddLineToPoint(path, NULL, p3.x, p3.y);
    CGPathAddLineToPoint(path, NULL, p1.x, p1.y);
    
    CGPathCloseSubpath(path);
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, redColor);
    CGContextAddPath(context, path);
    CGContextClip(context);
    drawGlossAndLinearGradient(context, rect, redColor, redColor);
    CGContextSaveGState(context);
    
    CFRelease(path);
}

//---------------------------------------------------------------
// Add Icon
//---------------------------------------------------------------

#pragma mark Add Icon

void drawAddIcon(CGContextRef context, CGRect rect) {
    CGColorRef fillColor = MK_COLOR_HSB(117.0, 96.0, 91.0, 1.0).CGColor;
    CGColorRef plusShadowColor = MK_COLOR_HSB(117.0, 96.0, 57.0, 1.0).CGColor;
    
    CGRect drawRect = CGRectInset(rect, 4.0, 4.0);
    CGRect plusRect = CGRectInset(drawRect, 5.0, 5.0);
    
    CGMutablePathRef path = createCircularPathForRect(drawRect);
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, fillColor);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextFillRect(context, drawRect);
    drawCurvedGloss(context, rect, rect.size.width);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, WHITE.CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0, 1.0), 3.0, MK_SHADOW_COLOR);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 3.0);
    CGContextSetStrokeColorWithColor(context, WHITE.CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0, -1.0), 1.0, plusShadowColor);
    CGContextMoveToPoint(context, CGRectGetMidX(plusRect), CGRectGetMinY(plusRect));
    CGContextAddLineToPoint(context, CGRectGetMidX(plusRect), CGRectGetMaxY(plusRect));
    CGContextMoveToPoint(context, CGRectGetMinX(plusRect), CGRectGetMidY(plusRect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(plusRect), CGRectGetMidY(plusRect));
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    CFRelease(path);
}

//---------------------------------------------------------------
// Subtract Icon
//---------------------------------------------------------------

#pragma mark Subtract Icon

void drawSubtractIcon(CGContextRef context, CGRect rect) {
    CGColorRef fillColor = RED.CGColor;
    CGColorRef plusShadowColor = RED.CGColor;
    
    CGRect drawRect = CGRectInset(rect, 4.0, 4.0);
    CGRect plusRect = CGRectInset(drawRect, 5.0, 5.0);
    
    CGMutablePathRef path = createCircularPathForRect(drawRect);
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, fillColor);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextFillRect(context, drawRect);
    drawCurvedGloss(context, rect, rect.size.width);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, WHITE.CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0, 1.0), 3.0, MK_SHADOW_COLOR);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 3.0);
    CGContextSetStrokeColorWithColor(context, WHITE.CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0, -1.0), 1.0, plusShadowColor);
    CGContextMoveToPoint(context, CGRectGetMinX(plusRect), CGRectGetMidY(plusRect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(plusRect), CGRectGetMidY(plusRect));
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    CFRelease(path);
}

@end


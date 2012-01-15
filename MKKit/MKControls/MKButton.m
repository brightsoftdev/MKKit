//
//  MKButton.m
//  MKKit
//
//  Created by Matthew King on 5/28/11.
//  Copyright 2011 Matt King. All rights reserved.
//

#import "MKButton.h"

#import <MKKit/MKKit/MKGraphics/MKGraphics.h>
#import "MKControl+Internal.h"

@interface MKButton ()

- (void)labelWithText:(NSString *)text;

@end

@implementation MKButton

@synthesize type=mType, buttonText=mButtonText, tintColor, fontSize, fontColor;

void drawHelpButton(CGContextRef context, CGRect rect);
void drawDiscloserButton(CGContextRef context, CGRect rect);
void drawIAPButton(CGContextRef context, CGRect rect, MKControlState state);
void drawPlasticButton(CGContextRef context, CGRect rect, MKGraphicsStructures *graphics, MKControlState state);
void drawRoundRectButton(CGContextRef context, CGRect rect, MKGraphicsStructures *graphics, MKControlState state);

bool mHighlighted = NO;

#pragma mark - Initalizer

- (id)initWithType:(MKButtonType)type {
    self = [super init];
    if (self) {
        self = [self initWithType:type title:nil graphics:nil];
    }
    return self;
}

- (id)initWithType:(MKButtonType)type title:(NSString *)title {
    self = [super init];
    if (self) {
        self = [self initWithType:type title:title graphics:nil];
    }
    return self;
}

- (id)initWithType:(MKButtonType)type title:(NSString *)title tint:(UIColor *)tint {
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithType:(MKButtonType)type title:(NSString *)title graphics:(MKGraphicsStructures *)graphics {
    self = [super initWithGraphics:graphics];
    if (self) {
        self.backgroundColor = CLEAR;
        self.opaque = NO;
        self.controlState = MKControlStateNormal;
        
        mType = type;
        if (!graphics) {
            self.graphicsStructure = [self defaultGraphics];
        }
        
        if  (mType == MKButtonTypeHelp) {
            MKButtonFlags.fontSize = kHelpButtonFontSize;
            [self labelWithText:@"?"];
        }
        
        if (mType == MKButtonTypeDisclosure) {
            self.frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
        }
        if (mType == MKButtonTypeIAP) {
            self.frame = CGRectMake(0.0, 0.0, (MK_TEXT_WIDTH(title, SYSTEM_BOLD(kIAPButtonFontSize)) + (kHorizPadding * 2)) ,30.0);
            MKButtonFlags.fontSize = kIAPButtonFontSize;
            [self labelWithText:title];
        }
        
        if (mType == MKButtonTypePlastic) {
            self.frame = CGRectMake(0.0, 0.0, (MK_TEXT_WIDTH(title, VERDANA_BOLD(kPlasticButtonFontSize)) + (kHorizPadding * 2)) ,30.0);
            MKButtonFlags.fontSize = kPlasticButtonFontSize;
            
            [self labelWithText:title];
        }
        
        if (mType == MKButtonTypeRoundedRect) {
            self.frame = CGRectMake(0.0, 0.0, (MK_TEXT_WIDTH(title, SYSTEM_BOLD(kRoundRectButtonFontSize)) + (kHorizPadding * 2)) ,30.0);
            MKButtonFlags.fontSize = kRoundRectButtonFontSize;
            
            [self labelWithText:title];
        }
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    
    if (mType == MKButtonTypeHelp) {
        drawHelpButton(context, rect);
    }
    else if (mType == MKButtonTypeDisclosure) {
        drawDiscloserButton(context, rect);
    }
    else if (mType == MKButtonTypeIAP) {
        drawIAPButton(context, rect, self.controlState);
    }
    else if (mType == MKButtonTypePlastic) {
        drawPlasticButton(context, rect, mGraphics, self.controlState);
        mButtonLabel.frame = rect;
    }
    else if (mType == MKButtonTypeRoundedRect) {
        drawRoundRectButton(context, rect, mGraphics, self.controlState);
        mButtonLabel.frame = rect;
    }
}

#pragma mark Help Button

void drawHelpButton(CGContextRef context, CGRect rect) {
    CGContextSetFillColorWithColor(context, WHITE.CGColor);
    CGContextAddEllipseInRect(context, rect);
    CGContextFillEllipseInRect(context, rect);
}

#pragma mark Discloser Button

void drawDiscloserButton(CGContextRef context, CGRect rect) {
    CGRect innerRect = CGRectInset(rect, kDiscloserOutlinePadding, kDiscloserOutlinePadding);
    
    CGColorRef borderColor = WHITE.CGColor;
    CGColorRef innerColor = MK_COLOR_RGB(0.0, 0.0, 255.0, 1.0).CGColor;
    
    CGMutablePathRef outerPath = createCircularPathForRect(rect);
    CGMutablePathRef innerPath = createCircularPathForRect(innerRect);
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, borderColor);
    CGContextAddPath(context, outerPath);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, innerColor);
    CGContextAddPath(context, innerPath);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    CGPoint p1 = CGPointMake(10.0, 7.0);
    CGPoint p2 = CGPointMake(16.0, 12.0);
    CGPoint p3 = CGPointMake(10.0, 17.0);
    
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, borderColor);
    CGContextSetLineWidth(context, 3.0);
    CGContextMoveToPoint(context, p1.x, p1.y);
    CGContextAddLineToPoint(context, p2.x, p2.y);
    CGContextAddLineToPoint(context, p3.x, p3.y);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, outerPath);
    CGContextClip(context);
    drawCurvedGloss(context, rect, 40.0);
    CGContextRestoreGState(context);
    
    CFRelease(outerPath);
    CFRelease(innerPath);
}

#pragma mark IAP Button

void drawIAPButton(CGContextRef context, CGRect rect, MKControlState state) {
    CGFloat outerMargin = 2.0;
    CGRect outerRect = CGRectInset(rect, outerMargin, outerMargin);
    CGMutablePathRef outerPath = createRoundedRectForRect(outerRect, 6.0);
        
    CGColorRef innerTop;
    CGColorRef innerBottom;
        
    CGColorRef blackColor = BLACK.CGColor;
    
    if (state != MKControlStateWorking) {
        innerTop = MK_COLOR_HSB(224.0, 57.0, 70.0, 1.0).CGColor;
        innerBottom = MK_COLOR_HSB(224.0, 57.0, 67.0, 1.0).CGColor;
    }
    else if (state == MKControlStateWorking) {
        innerTop = MK_COLOR_HSB(127.0, 84.0, 70.0, 1.0).CGColor;
        innerBottom = MK_COLOR_HSB(127.0, 84.0, 67.0, 1.0).CGColor;
    }

    if (state != MKControlStateHighlighted) {
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, innerBottom);
        CGContextAddPath(context, outerPath);
        CGContextFillPath(context);
        CGContextRestoreGState(context);
        
        CGContextSaveGState(context);
        CGContextAddPath(context, outerPath);
        CGContextClip(context);
        drawGlossAndLinearGradient(context, outerRect, innerTop, innerBottom);
        CGContextRestoreGState(context);
    }
        
    else {
        CGColorRef shadowColor = MK_COLOR_RGB(51.0, 51.0, 51.0, 0.9).CGColor;
            
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, shadowColor);
        CGContextAddPath(context, outerPath);
        CGContextFillPath(context);
        CGContextRestoreGState(context);
    }
        
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, blackColor);
    CGContextAddPath(context, outerPath);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
        
    CFRelease(outerPath);
}

#pragma mark Plastic Button

void drawPlasticButton(CGContextRef context, CGRect rect, MKGraphicsStructures *graphics, MKControlState state) {
    CGFloat margin = 1.0;
    CGRect buttonRect = CGRectInset(rect, margin, margin);
    
    CGMutablePathRef borderPath = createRoundedRectForRect(rect, 7.0);
    CGMutablePathRef buttonPath = createRoundedRectForRect(buttonRect, 6.0);

    CGColorRef bottom = bottomColorForControlState(state, graphics);
    CGColorRef border = graphics.border.color;
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, bottom);
    CGContextAddPath(context, buttonPath);
    CGContextFillPath(context),
    CGContextRestoreGState(context);
    
    if (state != MKControlStateHighlighted) {
        CGContextSaveGState(context);
        CGContextAddPath(context, buttonPath);
        CGContextClip(context);
        drawCurvedGloss(context, buttonRect, rect.size.width);
        CGContextRestoreGState(context);
    }
        
    drawOutlinePath(context, buttonPath, graphics.border.width, border);
    
    CFRelease(buttonPath);
    CFRelease(borderPath);
}

#pragma mark Rounded Rect Button

void drawRoundRectButton(CGContextRef context, CGRect rect, MKGraphicsStructures *graphics,  MKControlState state) {
    CGFloat margin = graphics.border.width;
    
    CGRect buttonRect = CGRectInset(rect, margin, margin);
    CGRect innerRect = CGRectInset(buttonRect, 1.0, 1.0);
    CGRect onePixRect = rectFor1pxStroke(innerRect);
    
    CGMutablePathRef rrectPath = createRoundedRectForRect(buttonRect, 10.0);
    CGMutablePathRef innerRectPath = createRoundedRectForRect(onePixRect, 10.0);
    
    CGColorRef top = topColorForControlState(state, graphics);
    CGColorRef bottom = bottomColorForControlState(state, graphics);
    CGColorRef border = graphics.border.color;
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, WHITE.CGColor);
    CGContextAddPath(context, rrectPath);
    CGContextFillPath(context),
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, rrectPath);
    CGContextClip(context);
    drawGlossAndLinearGradient(context, buttonRect, top, bottom);
    CGContextRestoreGState(context);
    
    drawOutlinePath(context, rrectPath, graphics.border.width, border);
    drawOutlinePath(context, innerRectPath, 1.0, bottom);
    
    CFRelease(innerRectPath);
    CFRelease(rrectPath);
}

#pragma mark - Accessor Methods

- (void)setButtonText:(NSString *)buttonText {
    mButtonText = [buttonText copy];
    
    CGFloat maxX = CGRectGetMaxX(self.frame);
    CGFloat minY = CGRectGetMinY(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
        
    CGFloat x = (maxX - (MK_TEXT_WIDTH(buttonText, SYSTEM_BOLD(MKButtonFlags.fontSize)) + (kHorizPadding * 2)));
    CGFloat width = (MK_TEXT_WIDTH(buttonText, SYSTEM_BOLD(MKButtonFlags.fontSize)) + (kHorizPadding * 2));
        
    self.frame = CGRectMake(x, minY, width, height);
        
    mButtonLabel.frame = CGRectMake(20.0, 4.5, MK_TEXT_WIDTH(buttonText, SYSTEM_BOLD(MKButtonFlags.fontSize)), 21.0);
    mButtonLabel.text = mButtonText;
    
    [self setNeedsDisplayInRect:CGRectMake(x, minY, width, height)];
    
    [mButtonText release];
}

- (void)setFontSize:(CGFloat)size {
    MKButtonFlags.fontSize = size;
    mButtonLabel.font = SYSTEM_BOLD(size);
}

- (void)setFontColor:(UIColor *)color {
    mButtonLabel.textColor = color;
}

#pragma mark - Elements

- (void)labelWithText:(NSString *)text {
    mButtonLabel = [[UILabel alloc] init];
    mButtonLabel.backgroundColor = CLEAR;
    mButtonLabel.textAlignment = UITextAlignmentCenter;
    mButtonLabel.shadowColor = BLACK;
    mButtonLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    mButtonLabel.text = text;
    
    if (mType == MKButtonTypeHelp) {
        mButtonLabel.frame = CGRectMake(1.0, 2.0, 19.0, 18.0);
        mButtonLabel.font = VERDANA_BOLD(MKButtonFlags.fontSize);
        mButtonLabel.textColor = GRAY;
    }
    if  (mType == MKButtonTypeIAP) {
        mButtonLabel.frame = CGRectMake(20.0, 4.5, MK_TEXT_WIDTH(text, SYSTEM_BOLD(MKButtonFlags.fontSize)), 21.0);
        mButtonLabel.textColor = WHITE;
        mButtonLabel.font = SYSTEM_BOLD(MKButtonFlags.fontSize);
        mButtonLabel.text = text;
    }
    if (mType == MKButtonTypeRoundedRect || mType == MKButtonTypePlastic) {
        mButtonLabel.textColor = WHITE;
        mButtonLabel.font = SYSTEM_BOLD(MKButtonFlags.fontSize);
        mButtonLabel.adjustsFontSizeToFitWidth = YES;
        mButtonLabel.text = text;
        mButtonLabel.shadowColor = self.graphicsStructure.bottomColor;
        
        if (mType == MKButtonTypePlastic) {
            mButtonLabel.font = VERDANA_BOLD(MKButtonFlags.fontSize);
        }
    }
    
    [self addSubview:mButtonLabel];
    [mButtonLabel release];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    //self.highlighted = NO;
    
    if (mType == MKButtonTypeIAP) {
        self.buttonText = @"Installing";
        self.controlState = MKControlStateWorking;
    }
    else {
        [self setNeedsDisplay];
    }
}

#pragma mark - Memory Managemnet

- (void)dealloc {
    self.buttonText = nil;
    self.fontColor = nil;
    
    [mGraphics release];
    
    [super dealloc];
}

@end

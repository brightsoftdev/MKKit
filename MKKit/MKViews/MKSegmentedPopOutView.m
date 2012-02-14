//
//  MKSegmentedPopOutView.m
//  MKKit
//
//  Created by Matthew King on 12/31/11.
//  Copyright (c) 2011-2012 Matt King. All rights reserved.
//

#import "MKSegmentedPopOutView.h"
#import <MKKit/MKKit/MKControls/MKControl.h>

#import "MKView+Internal.h"
#import "MKPopoutView+MKTableCell.h"

MKSegment MKSegmentMake(MKSegmentPosition pos, CFStringRef text, CGRect rect, int idnumber);
MKSegment MKSegmentMake(MKSegmentPosition pos, CFStringRef text, CGRect rect, int idnumber) {
    MKSegment segment;
    
    segment.pos = pos;
    segment.text = text;
    segment.idnumber = idnumber;
    segment.rect = rect;
    
    return segment;
}

CGRect rectForSegement(CGRect rect, int segment, int totalSegments); 

CGRect rectForText(CGRect rect);
CGRect rectForText(CGRect rect) {
    CGRect textRect;
    
    CGFloat y = (rect.origin.y + (rect.size.height - 20.0) / 2);
    
    textRect = CGRectMake(rect.origin.x, y, rect.size.width, 20.0);
    
    return textRect;
}

void drawSegmentText(CGContextRef context, CGRect rect, MKSegment segment);
void drawSegmentText(CGContextRef context, CGRect rect, MKSegment segment) {
    UIFont *font = [UIFont fontWithName:VERDANA_BOLD_FONT size:14.0];
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, WHITE.CGColor);
    [(NSString *)segment.text drawInRect:rect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    CGContextRestoreGState(context);
}

void drawSegmentSeperator(CGContextRef context, MKSegment segment);

@interface MKSegmentedPopOutView ()

- (void)selectedSegment:(NSInteger)index;

@end

@class MKSegmentView;

@implementation MKSegmentedPopOutView

@dynamic selectedIndex;

#pragma mark - Creation

- (id)initWithItems:(NSArray *)items type:(MKPopOutViewType)type graphics:(MKGraphicsStructures *)graphics {
    self = [super initWithFrame:CGRectMake(0.0, 0.0, 300.0, 70.0)]; 
    if (self) {
        mType = type;
        mItems = [items retain];
        mSelectedIndex = -1;
        
        self.alpha = 0.0;
        self.backgroundColor = CLEAR;
        self.opaque = YES;
        
        if (!graphics) {
            self.graphicsStructure = [self defaultGraphics];
        }
        else {
            self.graphicsStructure = graphics;
        }
        
        MKPopOutViewShouldRemoveNotification = @"MKPopOutViewShouldRemoveNotification";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeView) name:MKPopOutViewShouldRemoveNotification object:nil];
    }
    return self;
}

#pragma mark - Memory

- (void)dealloc {
    [mItems release];
    
    [mTargets removeAllObjects];
    [mTargets release];
    
    [super dealloc];
}

#pragma mark - Layout

- (void)layoutForMetrics:(MKViewMetrics)_metrics {
    [super layoutForMetrics:_metrics];
    
    if (mPopOutType == MKPopOutTableCell) {
        [self adjustToCell];
    }
}

#pragma mark - Accessor Methods
#pragma mark Getters

- (NSInteger)selectedIndex {
    return mSelectedIndex;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    
    CGRect drawRect = rectForType(mAutoType, rect);
    
    for (int i = 0; i < [mItems count]; i++) {
        MKSegmentPosition position = MKSegmentMid;
        if (i == 0) {
            position = MKSegmentLeft;
        }
        else if (i == ([mItems count] - 1)) {
            position = MKSegmentRight;
        }
        
        BOOL selected = NO;
        
        if (i == self.selectedIndex) {
            selected = YES;
        }
        
        CGRect segmentRect = rectForSegement(drawRect, i, [mItems count]);
        
        MKSegment segment = MKSegmentMake(position, (CFStringRef)[mItems objectAtIndex:i], segmentRect, i);
        
        CGContextBeginTransparencyLayer(context, NULL);
        drawSegmentSeperator(context, segment);
        CGContextEndTransparencyLayer(context);
        
        UIView *view = [self viewWithTag:i];
        
        if (view) {
            view.frame = segmentRect;
            [view setNeedsDisplayInRect:segmentRect];
        }
        else {
            MKSegmentView *segmentView = [[MKSegmentView alloc] initWithSegment:segment parent:self];
            segmentView.tag = i;
            [self addSubview:segmentView];
            [segmentView release];
        }
    }
}

#pragma mark Helpers

CGRect rectForSegement(CGRect rect, int segment, int totalSegments) {
    CGRect segmentRect;
    
    CGFloat width = (rect.size.width / totalSegments);
    CGFloat x = (rect.origin.x + ((segment * width)));
    
    segmentRect = CGRectMake(x, rect.origin.y, width, rect.size.height);
    
    return segmentRect;
}

void drawSegmentSeperator(CGContextRef context, MKSegment segment) {
    if (segment.pos != MKSegmentLeft) {
        CGContextSaveGState(context);
        CGContextSetStrokeColorWithColor(context, LIGHT_GRAY.CGColor);
        CGContextSetLineWidth(context, 1.0);
        CGContextMoveToPoint(context, CGRectGetMinX(segment.rect), CGRectGetMinY(segment.rect));
        CGContextAddLineToPoint(context, CGRectGetMinX(segment.rect), CGRectGetMaxY(segment.rect));
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
}

#pragma mark - Action Handling

- (void)addTarget:(id)target selector:(SEL)selector {
    if (!mTargets) {
        mTargets = [[NSMutableSet alloc] initWithCapacity:1];
    }
    
    MKControlTarget *newTarget = [[MKControlTarget alloc] init];
    newTarget.target = target;
    newTarget.selector = selector;
    
    [mTargets addObject:newTarget];
    [newTarget release];
}

- (void)selectedSegment:(NSInteger)index {
    for (MKControlTarget *target in mTargets) {
        [target.target performSelector:target.selector withObject:self];
    }
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //Overide super class touch events
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //Overide super class touch events
}

@end


@implementation MKSegmentView 

#pragma mark - Creation

- (id)initWithSegment:(MKSegment)segment parent:(MKSegmentedPopOutView *)parent {
    self = [super initWithFrame:segment.rect];
    if (self) {
        mParent = parent;
        mSegment = segment;
        
        self.backgroundColor = CLEAR;
    }
    return self;
}

#pragma mark - Memory

- (void)dealloc {
    [super dealloc];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    
    if (mSelected) {
        CGColorRef fillColor = mParent.graphicsStructure.touchedColor.CGColor;
        
        if (mSegment.pos == MKSegmentLeft) {
            CGMutablePathRef path = createLeftSideRoundedRectForRect(rect, 10.0);
            
            CGContextSaveGState(context);
            CGContextAddPath(context, path);
            CGContextClip(context);
            drawGlossAndLinearGradient(context, rect, fillColor, fillColor);
            CGContextRestoreGState(context);
        }
        else if (mSegment.pos == MKSegmentRight) {
            CGMutablePathRef path = createRighSideRoundedRectForRect(rect, 10.0);
            
            CGContextSaveGState(context);
            CGContextAddPath(context, path);
            CGContextClip(context);
            drawGlossAndLinearGradient(context, rect, fillColor, fillColor);
            CGContextRestoreGState(context);
        }
        else {
            CGContextSaveGState(context);
            drawGlossAndLinearGradient(context, rect, fillColor, fillColor);
            CGContextSaveGState(context);
        }
    }
        
    CGRect textRect = rectForText(rect);
    drawSegmentText(context, textRect, mSegment);
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    mParent->mSelectedIndex = mSegment.idnumber;
    mSelected = YES;
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [mParent selectedSegment:mSegment.idnumber];
}

@end
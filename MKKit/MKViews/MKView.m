//
//  MKView.m
//  MKKit
//
//  Created by Matthew King on 10/9/10.
//  Copyright 2010-2010 Matt King. All rights reserved.
//

#import "MKView.h"
#import "MKPopOverView.h"

#import "MKView+Internal.h"

@interface MKView ()

- (void)setUpView;

@end

@implementation MKView

@synthesize x, y, width, height, gradient, controller, delegate=mDelegate;

@dynamic graphicsStructure;

#pragma mark - Creating

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

#pragma mark Graphics Factory

- (id)initWithGraphics:(MKGraphicsStructures *)_graphicsStructure {
    self = [super init];
    if (self) {
        [self setUpView];
        
        if (_graphicsStructure) {
            self.graphicsStructure = [_graphicsStructure retain];
        }
        else {
            self.graphicsStructure = [self defaultGraphics];
        }
    }
    return self;
}

- (void)setUpView {
    self.userInteractionEnabled = YES;
    self.autoresizesSubviews = YES;
    
    mShouldRemoveView = YES;
    
    MKViewShouldRemoveNotification = @"MKViewShouldRemoveNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeView) name:MKViewShouldRemoveNotification object:nil];
}

#pragma mark - Memory Management

- (void)dealloc {
    self.controller = nil;
    self.graphicsStructure = nil;
    
    objc_removeAssociatedObjects(self);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKViewShouldRemoveNotification object:nil];
    
	[super dealloc];
}

#pragma mark - Accessor methods

#pragma mark Setters

- (void)setX:(CGFloat)point {
    self.frame = CGRectMake(point, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setY:(CGFloat)point {
    self.frame = CGRectMake(self.frame.origin.x, point, self.frame.size.width, self.frame.size.height);
}

- (void)setWidth:(CGFloat)lWidth {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, lWidth, self.frame.size.height);
}

- (void)setHeight:(CGFloat)lHeight {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, lHeight);
}

- (void)setGraphicsStructure:(MKGraphicsStructures *)_graphicsStructure {
    MKViewFlags.usesBackGroundFill = YES;
    mGraphics = [_graphicsStructure retain];
    [self setNeedsDisplay];
}

#pragma mark Getters

- (CGFloat)x {
    return self.frame.origin.x;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (MKGraphicsStructures *)graphicsStructure {
    return mGraphics;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    
    if (MKViewFlags.usesBackGroundFill) {
        drawWithGraphicsStructure(context, rect, self.graphicsStructure);
    }
}

#pragma mark - Showing the View

- (void)showWithAnimationType:(MKViewAnimationType)type; {
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    mAnimationType = type;
	
    if (type == MKViewAnimationTypeNone) {
        self.alpha = 1.0;
    }
    
    if (type == MKViewAnimationTypeFadeIn) {
        self.center = WINDOW_CENTER;
        
        [UIView animateWithDuration:0.25 
                         animations: ^ { self.alpha = 1.0; }];
    }
    
    if (type == MKViewAnimationTypeMoveInFromTop) {
        CGRect moveTo = self.frame;
               
        self.frame = CGRectMake(self.frame.origin.x, (0.0 - self.frame.size.height), self.frame.size.width, self.frame.size.height);
        
        self.alpha = 1.0;
        
        [UIView animateWithDuration:0.25
                         animations: ^ { self.frame = moveTo; }];
    }
    
    if (type == MKViewAnimationTypeAppearAboveToolbar) {
        self.frame = CGRectMake(CENTER_VIEW_HORIZONTALLY(320.0, self.frame.size.width), (460.0 - self.frame.size.height - TOOLBAR_HEIGHT -20.0), self.frame.size.width, self.frame.size.height);
        
        [UIView animateWithDuration:0.25
                         animations: ^ { self.alpha = 1.0; }];
    }
    
    if ([mDelegate respondsToSelector:@selector(MKViewDidAppear:)]) {
        [mDelegate MKViewDidAppear:self];
    }
}


- (void)showOnViewController:(UIViewController *)_controller animationType:(MKViewAnimationType)type {
    [_controller.view addSubview:self];
    
    CGFloat lheight = 460.0;
    CGFloat lwidth = 320.0; 
    
    if (_controller.interfaceOrientation == UIInterfaceOrientationPortrait || _controller.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        lheight = 460.0;
        lwidth = 320.0;
    }
    if (_controller.interfaceOrientation == UIInterfaceOrientationLandscapeRight || _controller.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        lheight = 300.0;
        lwidth = 480.0;
    }

    if (type == MKViewAnimationTypeNone) {
        self.alpha = 1.0;
    }
    
    if (type == MKViewAnimationTypeFadeIn) {
        self.frame = CGRectMake(CENTER_VIEW_HORIZONTALLY(lwidth, self.frame.size.width), ((lheight / 2.0) - (self.frame.size.height / 2.0)), self.frame.size.width, self.frame.size.height);
        
        [UIView animateWithDuration:0.25 
                         animations: ^ { self.alpha = 1.0; }];
    }
    
    if (type == MKViewAnimationTypeMoveInFromTop) {
        CGRect moveTo = self.frame;
        
        self.frame = CGRectMake(self.frame.origin.x, (0.0 - self.frame.size.height), lwidth, self.frame.size.height);
        
        self.alpha = 1.0;
        
        [UIView animateWithDuration:0.25
                         animations: ^ { self.frame = moveTo; }];
    }
    

    if (type == MKViewAnimationTypeAppearAboveToolbar) {
        self.frame = CGRectMake(CENTER_VIEW_HORIZONTALLY(lwidth, self.frame.size.width), (lheight - self.frame.size.height - TOOLBAR_HEIGHT -20.0), self.frame.size.width, self.frame.size.height);
        
        [UIView animateWithDuration:0.25
                         animations: ^ { self.alpha = 1.0; }];
    }
    
    if ([mDelegate respondsToSelector:@selector(MKViewDidAppear:)]) {
        [mDelegate MKViewDidAppear:self];
    }
}

#pragma mark - Removing

- (void)removeView {
    if ([mDelegate respondsToSelector:@selector(shouldRemoveView:)]) {
        mShouldRemoveView = [mDelegate shouldRemoveView:self];
    }
    
    if (mShouldRemoveView) {
        if (mAnimationType == MKViewAnimationTypeNone) {
            [self removeFromSuperview];
        }
        
        if (mAnimationType == MKViewAnimationTypeFadeIn || mAnimationType == MKViewAnimationTypeAppearAboveToolbar) {
            [UIView animateWithDuration:0.25
                             animations: ^ { self.alpha = 0.0; }
                             completion: ^ (BOOL finished) { [self removeFromSuperview]; }];
        }
        
        if (mAnimationType == MKViewAnimationTypeMoveInFromTop) {
            CGRect moveTo = CGRectMake(self.frame.origin.x, (0.0 - self.frame.size.height), self.frame.size.width, self.frame.size.height);
            
            [UIView animateWithDuration:0.25 
                             animations: ^ { self.frame = moveTo; }
                             completion: ^ (BOOL finished) { [self removeFromSuperview]; }];
        }
    }
}

@end

///// DEPRECATED CATAGORY ////// 

@implementation MKView (IconMask) 

@dynamic image;

#pragma mark - Initalizer

- (id)initWithImage:(UIImage *)image gradient:(MKGraphicsStructures *)aGradient {
    /*
    self = [super initWithFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    if (self) {
        self.backgroundColor = CLEAR;
        self.opaque = YES;
        self.alpha = 1.0;
        
        self.image = image;
        
        MKViewFlags.usesGradient = YES;
        self.gradient = aGradient;
        
        mShouldRemoveView = NO;
        MKViewFlags.isIconMask = YES;
    }
    */
    return nil;
}

#pragma mark - Accessor Methods
#pragma mark setters
- (void)setImage:(UIImage *)image {
    /*
    objc_setAssociatedObject(self, ImageTag, image, OBJC_ASSOCIATION_RETAIN);
    [self setNeedsDisplay];
    */
}

#pragma mark getters

- (UIImage *)image {
    /*
    return objc_getAssociatedObject(self, ImageTag);
    */
    return nil;
}

@end
//
//  MKTableCellSlider.m
//  MKKit
//
//  Created by Matthew King on 1/24/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKTableCellSlider.h"

//---------------------------------------------------------------
// Interface
//---------------------------------------------------------------

@interface MKSliderTracking : UISlider 

@end

@interface MKTableCellSlider ()

- (void)slideEnded:(id)sender;

@end

#pragma mark -

//---------------------------------------------------------------
// Implementaion (MKTableCellSlider)
//---------------------------------------------------------------

@implementation MKTableCellSlider

@synthesize slider;

#pragma mark - Creation

//---------------------------------------------------------------
// Creation
//---------------------------------------------------------------

- (id)initWithType:(MKTableCellType)cellType reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithType:MKTableCellTypeNone reuseIdentifier:reuseIdentifier];
    if (self) {
        mCellView = [[MKView alloc] initWithCell:self];
        
        self.slider = [[MKSliderTracking alloc] initWithFrame:CGRectZero];
        self.slider.continuous = NO;
        [self.slider addTarget:self action:@selector(slideEnded:) forControlEvents:UIControlEventValueChanged];
        
        [mCellView addPrimaryElement:self.slider];
        [self.contentView addSubview:mCellView];
        
        [mCellView release];
    }
    return self;
}

#pragma mark - Memory

//---------------------------------------------------------------
// Memory
//---------------------------------------------------------------

- (void)dealloc {
    self.slider = nil;
    
    [super dealloc];
}

#pragma mark - Actions

//---------------------------------------------------------------
// Action Responces
//---------------------------------------------------------------

- (void)slideEnded:(id)sender {
    NSNumber *value = [NSNumber numberWithFloat:[(UISlider *)sender value]];
    if ([self.delegate respondsToSelector:@selector(valueDidChange:forKey:)]) {
        [self.delegate valueDidChange:value forKey:self.key];
    }
}

@end

#pragma mark -

//---------------------------------------------------------------
// Implementaion (MKSliderTracking)
//---------------------------------------------------------------

@implementation MKSliderTracking

#pragma mark - Touch Tracking

//---------------------------------------------------------------
// Touch Tracking
//---------------------------------------------------------------

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    //NSLog(@"Begin");
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    //NSLog(@"Traking");
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    //NSLog(@"End");
}

@end

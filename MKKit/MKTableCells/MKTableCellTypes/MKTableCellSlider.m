//
//  MKTableCellSlider.m
//  MKKit
//
//  Created by Matthew King on 1/24/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKTableCellSlider.h"

@interface MKTableCellSlider ()

- (void)slideEnded:(id)sender;

@end

@implementation MKTableCellSlider

@synthesize slider;

#pragma mark - Creation

- (id)initWithType:(MKTableCellType)cellType reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithType:MKTableCellTypeNone reuseIdentifier:reuseIdentifier];
    if (self) {
        mCellView = [[MKView alloc] initWithCell:self];
        
        self.slider = [[UISlider alloc] initWithFrame:CGRectZero];
        self.slider.continuous = NO;
        [self.slider addTarget:self action:@selector(slideEnded:) forControlEvents:UIControlEventValueChanged];
        
        [mCellView addPrimaryElement:self.slider];
        [self.contentView addSubview:mCellView];
        
        [mCellView release];
    }
    return self;
}

#pragma mark - Memory

- (void)dealloc {
    self.slider = nil;
    
    [super dealloc];
}

#pragma mark - Actions

- (void)slideEnded:(id)sender {
    NSNumber *value = [NSNumber numberWithFloat:[(UISlider *)sender value]];
    if ([self.delegate respondsToSelector:@selector(valueDidChange:forKey:)]) {
        [self.delegate valueDidChange:value forKey:self.key];
    }
}


@end

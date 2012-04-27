//
//  MKView+MKTitleView.m
//  MKKit
//
//  Created by Matthew King on 12/5/11.
//  Copyright (c) 2011 Matt King. All rights reserved.
//

#import "MKView+MKTitleView.h"

static const char *TitleLabelKey = "TitleLabelKey";

@implementation MKView (MKTitleView)

@dynamic titleLabel;

#pragma mark - Creation

+ (id)titleViewWithTitle:(NSString *)title image:(MKImage *)icon {
    return [[[self alloc] initWithTitle:title image:icon] autorelease];
}

- (id)initWithTitle:(NSString *)title image:(MKImage *)icon {
    self = [super initWithFrame:CGRectMake(0.0, 0.0, (MK_TEXT_WIDTH(title, VERDANA_BOLD(20.0)) + 32.0), 32.0)];
    if (self) {
        self.backgroundColor = CLEAR;
        self.autoresizesSubviews = YES;
        self.opaque = YES;
        self.alpha = 1.0;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:(UIImage *)icon];
        imageView.frame = CGRectMake(0.0, 2.0, 25.0, 25.0);
        imageView.tag = kMKTtileViewImageViewTag;
        [self addSubview:imageView];
        [imageView release];
        
        [self titleViewLabelWithText:title];        
        mShouldRemoveView = NO;
    }
    return self;
}

#pragma mark - Helpers

- (void)titleViewLabelWithText:(NSString *)text {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(32.0, 5.0, MK_TEXT_WIDTH(text, VERDANA_BOLD(20.0)), 23.0)];
    self.titleLabel.backgroundColor = CLEAR;
    self.titleLabel.font = VERDANA_BOLD(20.0);
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.textColor = WHITE;
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.titleLabel.shadowColor = BLACK;
    self.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    self.titleLabel.text = text;
    
    [self addSubview:self.titleLabel];
}

#pragma mark - Accessor Methods
#pragma mark Setters

- (void)setTitleLabel:(UILabel *)titleLabel {
    objc_setAssociatedObject(self, TitleLabelKey, titleLabel, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark Getters

- (UILabel *)titleLabel {
    return (UILabel *)objc_getAssociatedObject(self, TitleLabelKey);
}

@end

//
//  MKView+MKTableHeader.m
//  MKKit
//
//  Created by Matthew King on 1/2/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKView+MKTableHeader.h"
#import "MKView+Internal.h"

@implementation MKView (MKTableHeader)

@dynamic titleLabel;

static const char *TitleLableKey = "TitleLabelKey";

#pragma mark - Initalizers

- (id)initWithTitle:(NSString *)title type:(MKTableHeaderType)type graphics:(MKGraphicsStructures *)graphics {
    self = [super initWithFrame:CGRectMake(0.0, 0.0, 303.0, 20.0)];
    if (self) {
        self.backgroundColor = CLEAR;
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.graphicsStructure = [graphics retain];
        
        if (!self.graphicsStructure) {
            self.graphicsStructure = [self defaultGraphics];
        }
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.0, self.frame.origin.x, self.frame.size.width, self.frame.size.height)];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        self.titleLabel.backgroundColor = CLEAR;
        self.titleLabel.font = SYSTEM_BOLD(14.0);
        self.titleLabel.textColor = WHITE;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumFontSize = 12.0;
        self.titleLabel.text = title;
        
        [self addSubview:self.titleLabel];
        
        MKViewFlags.usesBackGroundFill = YES;
        
        if (type == MKTableHeaderTypePlain) {
            self.titleLabel.textAlignment = UITextAlignmentLeft;
        }
    }
    return self;
}

+ (id)headerViewWithTitle:(NSString *)title type:(MKTableHeaderType)type graphics:(MKGraphicsStructures *)graphics {
    return [[[[self class] alloc] initWithTitle:title type:type graphics:graphics] autorelease];
}

#pragma mark - Accessor Methods

#pragma mark Setters

- (void)setTitleLabel:(UILabel *)label {
    objc_setAssociatedObject(self, TitleLableKey, label, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark Getters

- (UILabel *)titleLabel {
    return (UILabel *)objc_getAssociatedObject(self, TitleLableKey);
}

#pragma mark - Deprecated v1.0

- (id)initWithTitle:(NSString *)title type:(MKTableHeaderType)type {
    return nil;
}

+ (id)headerViewWithTitle:(NSString *)title type:(MKTableHeaderType)type {
    return nil;
}

@end

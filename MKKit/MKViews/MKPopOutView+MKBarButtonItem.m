//
//  MKPopOutView+MKBarButtonItem.m
//  MKKit
//
//  Created by Matthew King on 12/17/11.
//  Copyright (c) 2011-2012 Matt King. All rights reserved.
//

#import "MKPopOutView+MKBarButtonItem.h"

#import <MKKit/MKKit/MKControls/MKBarButtonItem.h>

@implementation MKPopOutView (MKBarButtonItem)

#pragma mark - Display

- (void)showFromButton:(MKBarButtonItem *)_button onView:(UIView *)view {
    self.button = _button;
    
    mAutoType = self.type;
    mPopOutType = MKPopOutBarButton;
    
    self.frame = CGRectMake(10.0, 0.0, 300.0, self.height);
    self.alpha = 0.0;
    
    [view addSubview:self];
    [self adjustToButton];
    
    [UIView animateWithDuration:0.25
                     animations: ^ {
                         self.alpha = 1.0;
                     }];
}

- (void)adjustToButton {
   CGPoint buttonCenter = CGPointMake(CGRectGetMidX(self.button.bounds), CGRectGetMidY(self.button.bounds));
    
    if (self.button) {
        self.arrowPosition = [self.button convertPoint:buttonCenter toView:self].x;
        
        if (MK_DEVICE_IS_IPAD) {
            self.frame = CGRectMake((self.arrowPosition - (self.frame.size.width / 2.0) + (self.button.frame.size.width / 2.0)), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            self.arrowPosition = CGRectGetMidX(self.bounds);
        }
    }
}

@end

//
//  UIViewController+MKVIewController.m
//  MKKit
//
//  Created by Matthew King on 1/20/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "UIViewController+MKVIewController.h"

#import "MKContainerControllers/MKDisclosureViewController.h"

@implementation UIViewController (MKVIewController)

#pragma mark - Accessor Methods
#pragma mark Getters

- (MKDisclosureViewController *)disclosureController {
    if ([[self parentViewController] isKindOfClass:[MKDisclosureViewController class]]) {
        return (MKDisclosureViewController *)self.parentViewController;
    }
    return nil;
}

- (void)didDiscloseView {
    //For use by subclasses
}

@end

//
//  UIViewController+MKVIewController.m
//  MKKit
//
//  Created by Matthew King on 1/20/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "UIViewController+MKVIewController.h"

#import "MKContainerControllers/MKSplitViewController.h"

@implementation UIViewController (MKVIewController)

- (MKSplitViewController *)dynamicSplitViewController {
    if ([[self parentViewController] isKindOfClass:[MKSplitViewController class]]) {
        return (MKSplitViewController *)self.parentViewController;
    }
    return nil;
}

@end

//
//  MKView+Internal.m
//  MKKit
//
//  Created by Matthew King on 12/30/11.
//  Copyright (c) 2011 Matt King. All rights reserved.
//

#import "MKView+Internal.h"

#import "MKPopOutView.h"
#import "MKLoadingView.h"
#import "MKSegmentedPopOutView.h"

@implementation MKView (Internal)

- (void)didRelease {
    
}

- (MKGraphicsStructures *)defaultGraphics {
    MKGraphicsStructures *graphics = [MKGraphicsStructures graphicsStructure];
    
    if ([self isMemberOfClass:[MKPopOutView class]]) {
        graphics.fillColor = BLACK;
        graphics.useLinerShine = YES;
    }
    if ([self isMemberOfClass:[MKSegmentedPopOutView class]]) {
        graphics.fillColor = BLACK;
        graphics.touchedColor = BLUE;
        graphics.useLinerShine = YES;
    }
    if ([self isMemberOfClass:[MKLoadingView class]]) {
        graphics.fillColor = BLACK;
    }
    
    return graphics;
}

@end

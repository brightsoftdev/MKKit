//
//  MKControl+Internal.m
//  MKKit
//
//  Created by Matthew King on 12/26/11.
//  Copyright (c) 2011 Matt King. All rights reserved.
//

#import "MKControl+Internal.h"

#import "MKBarButtonItem.h"
#import "MKButton.h"
#import "MKPaging.h"

@implementation MKControl (Internal)

- (void)setUpControl {
    
}

- (MKGraphicsStructures *)defaultGraphics {
    MKGraphicsStructures *graphics = [MKGraphicsStructures graphicsStructure];
    
    if ([self isMemberOfClass:[MKBarButtonItem class]]) {
        graphics.fillColor = [UIColor whiteColor];
        graphics.touchedColor = [UIColor whiteColor];
        graphics.disabledColor = MK_COLOR_HSB(345.0, 1.0, 99.0, 0.50);
    }
    if ([self isMemberOfClass:[MKButton class]]) {
        if ([(MKButton *)self type] == MKButtonTypeRoundedRect) {
            graphics.topColor = MK_COLOR_HSB(240.0, 98.0, 98.0, 0.5);
            graphics.bottomColor = MK_COLOR_HSB(240.0, 98.0, 98.0, 1.0);
            graphics.disabledColor = MK_COLOR_HSB(240.0, 98.0, 98.0, 0.25);
            graphics.touchedColor = MK_COLOR_HSB(240.0, 98.0, 98.0, 1.0);
            graphics.border = MKGraphicBorderMake(2.0, [UIColor blackColor]);
        }
        if ([(MKButton *)self type] == MKButtonTypePlastic) {
            graphics.fillColor = MK_COLOR_HSB(345.0, 0.0, 0.0, 1.0);
            graphics.border = MKGraphicBorderMake(2.0, [UIColor blackColor]);
        }
    }
    if ([self isMemberOfClass:[MKPaging class]]) {
        graphics.fillColor = MK_COLOR_RGB(1.0, 1.0, 1.0, 1.0);
        graphics.disabledColor = MK_COLOR_RGB(1.0, 1.0, 1.0, 0.5);
    }
    
    return graphics;
}

@end

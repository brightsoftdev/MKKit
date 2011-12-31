//
//  MKImage.m
//  MKKit
//
//  Created by Matthew King on 12/3/11.
//  Copyright (c) 2011 Matt King. All rights reserved.
//

#import "MKImage.h"

@interface MKImage () 

- (id)initWithName:(NSString *)name graphicStruct:(MKGraphicsStructures *)graphicStruct;
- (MKImage *)maskFromImage:(UIImage *)image graphicStruct:(MKGraphicsStructures *)graphicStruct;
- (MKGraphicsStructures *)defaultGraphics;

@end

@implementation MKImage 

#pragma mark - Creation

+ (id)imagedNamed:(NSString *)imageName graphicStruct:(MKGraphicsStructures *)graphicStruct {
    return [[[self alloc] initWithName:imageName graphicStruct:graphicStruct] autorelease];
}

- (id)initWithName:(NSString *)name graphicStruct:(MKGraphicsStructures *)graphicStruct {
    self = [super init];
    if (self) {
        self = [self maskFromImage:[UIImage imageNamed:name] graphicStruct:graphicStruct];
        [self retain];
    }
    return self;
}

- (id)initWithContentsOfFile:(NSString *)path graphicStruct:(MKGraphicsStructures *)graphicStruct {
    self = [super initWithContentsOfFile:path];
    if (self) {
        self = [self maskFromImage:self graphicStruct:graphicStruct];
    }
    return self;
}

#pragma mark - Memory Managment

- (void)dealloc {
    [super dealloc];
}

#pragma mark - Default Graphics

- (MKGraphicsStructures *)defaultGraphics {
    MKGraphicsStructures *graphics = [MKGraphicsStructures graphicsStructure];
    graphics.fillColor = [UIColor blackColor];
    
    return graphics;
}

#pragma mark - Masking

- (MKImage *)maskFromImage:(UIImage *)image graphicStruct:(MKGraphicsStructures *)graphicStruct {
    if (!graphicStruct) {
        graphicStruct = [self defaultGraphics];
    }
    
    CGRect imageRect = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width, image.size.height), NO, 2.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    
    CGColorRef bgColor;
    
    if (graphicStruct.shadowed) {
        bgColor = [UIColor whiteColor].CGColor;
        CGContextSetShadowWithColor(context, graphicStruct.shadow.offset, graphicStruct.shadow.blur, graphicStruct.shadow.color);
    }
    else {
        bgColor = [UIColor clearColor].CGColor;
    }
        
    CGContextBeginTransparencyLayer(context, NULL);
    CGContextTranslateCTM(context, 0.0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, imageRect, imageRef);
    CGContextSetFillColorWithColor(context, bgColor);
    CGContextFillRect(context, imageRect);
    CGContextEndTransparencyLayer(context);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, image.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, imageRect, imageRef);
    drawLinearGradient(context, imageRect, graphicStruct.fillColor.CGColor, graphicStruct.fillColor.CGColor);    
    CGContextRestoreGState(context);
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
       
    MKImage *rtnImage = (MKImage *)finalImage;
        
    return rtnImage;
}

@end

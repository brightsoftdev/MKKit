//
//  MKDocument.h
//  MKKit
//
//  Created by Matthew King on 3/28/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKDocument : UIDocument

@property (nonatomic, retain) NSData *content;

//@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, assign) BOOL cloudDocument;

@end

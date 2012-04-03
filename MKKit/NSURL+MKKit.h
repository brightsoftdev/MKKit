//
//  NSURL+MKKit.h
//  MKKit
//
//  Created by Matthew King on 3/30/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (MKKit)

///--------------------------------
/// @name Local Directory URLs
///--------------------------------

+ (NSURL *)documentsDirectoryURL;

///--------------------------------
/// @name Cloud Directroy URLs
///--------------------------------

+ (NSURL *)ubiquitousDocumentsDirectoryURL;

@end

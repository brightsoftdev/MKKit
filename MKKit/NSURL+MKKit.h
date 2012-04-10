//
//  NSURL+MKKit.h
//  MKKit
//
//  Created by Matthew King on 3/30/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import <Foundation/Foundation.h>

/**--------------------------------------------------
 *Overview*
 
 This catagory preforms specialty NSURL functions.
---------------------------------------------------*/

@interface NSURL (MKKit)

///--------------------------------
/// @name Local Directory URLs
///--------------------------------

/**
 Returns the URL for the apps local documents diretory.
 
 @return NSURL instance
*/
+ (NSURL *)documentsDirectoryURL;

///--------------------------------
/// @name Cloud Directroy URLs
///--------------------------------

/**
 Returns the URL of the apps cloud documents directory.
 
 @return NSURL instance
*/
+ (NSURL *)ubiquitousDocumentsDirectoryURL;

@end

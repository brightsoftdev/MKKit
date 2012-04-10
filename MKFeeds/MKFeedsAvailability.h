//
//  MKFeedsAvailability.h
//  MKKit
//
//  Created by Matthew King on 10/19/11.
//  Copyright (c) 2011 Matt King. All rights reserved.
//

////////////////////////////////////////////////////////////////
// TOGGLE THE MACRO TO MAKE MKKIT AVAILABLE TO MKFEEDS.       //
//                                                            //
// THE FOLLOWING FUNCTIONS OF MKFEEDS REQUIRE MKKIT FOR USAGE //
// * CLOUD SYNC AND CLOUD ARCHIVING OF FEED RESULTS           //
////////////////////////////////////////////////////////////////

#define MKKIT_AVAILABLE_TO_MKFEEDS              0  // 1=AVAILABLE 0=NONAVAILABLE // 

#if MKKIT_AVAILABLE_TO_MKFEEDS
    #import <MKKit/MKKit/MKMacros.h>
    #import <MKKit/MKKit/MKCloud.h>
    #import <MKKit/MKKit/MKDocument.h>
#else
    #define MK_VISIBLE_ATTRIBUTE                __attribute__((visibility ("default")))
    #define MK_DEPRECATED_1_0                   __attribute__((deprecated))
    #define MK_DEVICE_IS_IPAD                   [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
    #define MK_DEVICE_IS_IPHONE                 [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone
#endif
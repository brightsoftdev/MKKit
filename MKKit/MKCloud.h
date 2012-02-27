//
//  MKCloud.h
//  MKKit
//
//  Created by Matthew King on 2/25/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKObject.h"

typedef void (^MKCloudLoadedFileHandler)(NSURL *fielURL);

/**--------------------------------------------------------------------------
 *Overview*
 
 MKCloud provides some basic funtions for using iCloud data storage. 
---------------------------------------------------------------------------*/

@interface MKCloud : MKObject {
@private
    NSMetadataQuery *mQuery;
    
}

///-------------------------------
/// @name Creating Instances
///-------------------------------

/**
 Creates an autoreleasing instance MKCloud.
 
 This should be the only method used to create an instance.
 
 @return MKCloud instance
*/
+ (id)cloudManager;

///-------------------------------
/// @name Availability
///-------------------------------

/**
 Checks if iCloud is available for the current device/user. 
 returns `YES` if available, `NO` if not.
*/
+ (BOOL)iCloudIsAvailable;

///-------------------------------
/// @name Load Files
///-------------------------------

/**
 Checks if the given file exists in the local cloud directory and retuns an NSURL 
 instance if the file exists.
 
 @param name the name of the file to search for
 
 @param result the block to excute when the file is found.
*/
- (void)urlForFileNamed:(NSString *)name result:(MKCloudLoadedFileHandler)result;

///-------------------------------
/// @name Blocks
///-------------------------------

/** Reference to the file query result handler */
@property (nonatomic, copy) MKCloudLoadedFileHandler loadFileHandler;

@end

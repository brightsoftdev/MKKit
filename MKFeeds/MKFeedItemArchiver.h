//
//  MKFeedItemArchiver.h
//  MKKit
//
//  Created by Matthew King on 2/17/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    MKArchiverSyncIncomplete,
    MKArchiverSyncComplete,
    MKArchiverSyncFailed,
} MKArchiverSyncResults;

@class MKFeedParser;

/**-----------------------------------------------------------------------------------
 *Overview*
 
 MKFeedArchiver provides methods to save requests results from MKFeedParser to the device
 disk. MKFeedArchiver creates and saves arrays of MKFeedItem instances or syncs an array 
 with an existing file.
 
 *Usage*
 
 Call the setArchiveResults:path:successful: method of an MKFeedParser instance to automatically
 sync the results to an archive. You can also use this class directly to archive feed items
 on your own.  
 
 @warning *Note* MKFeedArchiver contains heavy processing methods. Its is recomended that it
 used off of the main thread.
------------------------------------------------------------------------------------*/

@interface MKFeedItemArchiver : NSObject {
    NSArray *mItems;
}

///------------------------------------------------
/// @name Creating
///------------------------------------------------

/**
 Creates an instance of MKFeedItemArchiver and prepears the given array for archiving.
 
 @param items and array of MKFeedItem instances
 
 @return MKFeedItemArchiver instance.
*/
- (id)initWithItems:(NSArray *)items;

///------------------------------------------------
/// @name Archiving
///------------------------------------------------

/**
 Archives the items from the array to the provided path. If a file already exists at the 
 given path it will be overwritten.
 
 @param path the path to write the archive file to.
 
 @param completion the block called upon the completion of the sync. Returns `YES` if the 
 sync was successful, `NO` if it was not.
 
 * `MKArchiverSyncIncomplete` : sync was successful, but there may be a gap in the items.
 * `MKArchiverSyncComplete` : sync was successful.
 * `MKArchiverSyncFailed` : sync was not successful.
 
*/
- (void)archiveToFileAtPath:(NSString *)path completion:(void (^) (BOOL finished))completion;

///--------------------------------------------------
/// @name Syncing
///--------------------------------------------------

/**
 Syncs items from the array provided at creation and writes the new file to disk, or creates
 a file if one does not exist. New items are added to the top of the existing stack.
 
 @param path the path of the file to sync with. This should be a file that was created by 
 MKFeedItemArchiver.
 
 @param completion the block called upon the completion of the sync. Returns one of three
 `MKArchiverSyncResults`:
 
 * `MKArchiverSyncIncomplete` : sync was successful, but there may be a gap in the items.
 * `MKArchiverSyncComplete` : sync was successful.
 * `MKArchiverSyncFailed` : sync was not successful.
*/
- (void)syncWithArchiveFileAtPath:(NSString *)path completion:(void (^) (MKArchiverSyncResults syncResults))completion;

/**
 Syncs items from the array provided at creation and writes the new file to cloud. New items are added 
 to the top of the existing stack.
 
 @param URL the url of the file to sync with. The archiver assumes that checks have been
 made to make sure the file is present.
 
 @param completion the block called upon the completion of the sync. Returns one of three
 `MKArchiverSyncResults`:
 
 * `MKArchiverSyncIncomplete` : sync was successful, but there may be a gap in the items.
 * `MKArchiverSyncComplete` : sync was successful.
 * `MKArchiverSyncFailed` : sync was not successful.
 
*/
- (void)syncWithCloudFileAtURL:(NSURL *)URL completion:(void (^) (MKArchiverSyncResults syncResults))completion;

///--------------------------------------------------
/// @name Overwriting
///--------------------------------------------------

/**
 Adds the entire array given at creation to the end of the current stack.
 
 @param path the path of file to add the array to.
 
 @return YES if the successful, NO if not.
*/
- (BOOL)addAllItemsToPath:(NSString *)path;

/**
 Adds the entire array given at creation to the end of the current stack.
 
 @param URL the URL location of the local cloud file
 
 @return YES if the successful, NO if not.
*/
- (BOOL)addAllItemsToCloudURL:(NSURL *)URL;

@end

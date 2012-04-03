//
//  MKCloud.h
//  MKKit
//
//  Created by Matthew King on 2/25/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>

#import "MKObject.h"

@class MKDocument;

/**--------------------------------------------------------------------------
 *Overview*
 
 MKCloud provides some basic funtions for using iCloud data storage. 
---------------------------------------------------------------------------*/

@interface MKCloud : MKObject {
@private
    NSMetadataQuery *mQuery;
    dispatch_queue_t backgroundqueue; 
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
/// @name Manage Documents
///-------------------------------

- (void)addDocument:(MKDocument *)document;

- (void)removeDocument:(MKDocument *)document;

///-------------------------------
/// @name Getting Documents
///-------------------------------

- (MKDocument *)documentNamed:(NSString *)name;

@property (retain) NSMutableSet *documents;

///-------------------------------
/// @name Document Operations
///-------------------------------

- (void)createDocumentNamed:(NSString *)name content:(NSData *)content successful:(void(^)(BOOL successful))successful;

- (void)openDocumentNamed:(NSString *)name content:(void(^)(id content))content;

- (void)saveDocumentNamed:(NSString *)name successful:(void(^)(BOOL successful))successful;

- (void)closeDocumentNamed:(NSString *)name successful:(void(^)(BOOL sucessful))successful;

///-------------------------------
/// @name Cloud Operations
///-------------------------------

- (void)pushDocumentToCloud:(MKDocument *)document named:(NSString *)name successful:(void(^)(BOOL successful))successful; 

- (void)removeDocumentNamed:(NSString *)name successful:(void(^)(BOOL successful))successful;

/**
 Checks if the given file exists in the local cloud directory and retuns an NSURL 
 instance if the file exists.
 
 @param name the name of the file to search for
 
 @param result the block to excute when the file is found.
*/
- (void)urlForFileNamed:(NSString *)name result:(void(^)(NSURL *fielURL))result;

/**
 Removes a file from the cloud if the file exists.
 
 @param name the name of the file to remove
 
 @param directory the directory if any the file was saved into or nil if no directory was used.
 
 @param successful the code block to be preformed upon the completion of the file removal. 
*/
//- (void)removeCloudFileNamed:(NSString *)name directory:(NSString *)directory successful:(void(^)(BOOL successful))successful;


@end

//
//  MKRSSFeed.h
//  MKKit
//
//  Created by Matthew King on 8/13/10.
//  Copyright 2010-2011 Matt King. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKFeedsAvailability.h"
#import "MKFeedsErrorControl.h"
#import "MKFeedItemArchiver.h"

typedef void (^MKRequestComplete)(NSArray *feedInfo, NSError *error);
typedef void (^MKArchiveSuccessful)(BOOL successful);

typedef enum {
    MKFeedContentPlainText,
    MKFeedContentTypeHTMLEntities,
    MKFeedContentHTML,
} MKFeedContentType;

typedef enum {
    MKFeedSourceRSS,
    MKFeedSourceAtom,
    MKFeedSourceTypeGoogleFeedAPIJSON,
    MKFeedSourceTypeUnknown,
} MKFeedSourceType;

typedef enum {
    MKFeedArchiveWithFile,
    MKFeedArchiveWithCloud,
} MKFeedArchiveType;

@class MKFeedItem;
@protocol MKFeedParserDelegate;

/**---------------------------------------------------------------------------------
 *Overview*
 
 MKFeedParser requests RSS/ATOM feeds from the internet and pases them into an array for 
 use by your app. MKFeedParser passes the provided URL through Google's feed API and than
 parses it into an array of MKFeedItem objects. 
 
 *Using Returned Data*
 
 Data can returned through ethier the MKFeedParserDelegate or the MKRequestComplete block.
 Both methods pass an NSArray that holds the information from the feed. The array is an array
 of MKFeedItem instaces. 
 
 *Archiving Results*
 
 MKFeedParser instances can automatically archive the results of the request to disk by using
 MKFeedItemArchiver. Set the archiveResults, and archivePath properties, or call the 
 setArchiveResultsToPath:successful: method to create or sync to an archive file. 
 
 MKFeedParser can sync to iCloud documents as well use the setArchiveResultsToCloudURL:successful:
 method to sync to the cloud.
 
 @warning *Note* MKFeedParser assumes that all the require iCloud use checks have been done prior
 to requesting data.  It does not check for iCloud avialbility or the existance of a file at the 
 given file URL.
 
 If you set the properties yourself the feed:didArchiveResults: delegate method will notify
 you of an archives success or failure.  If you use the  setArchiveResultsToPath:successful:
 the successful block is called upon completion.
----------------------------------------------------------------------------------*/

@interface MKFeedParser : NSObject <NSXMLParserDelegate> {
	NSString *mUrl;
	id delegate;
    MKRequestComplete mRequestCompleteBlock;
    
@private
	NSMutableURLRequest *urlRequest; 
	NSMutableData *requestData;
    NSURLConnection *theConnection;
    NSURLCache *requestCache;
    
    MKFeedArchiveType mArchiveType;

    struct {
        BOOL usesCompletionBlock;
    } MKRSSFeedTags;
}

///---------------------------------------------
/// @name Creating
///---------------------------------------------

/**
 Creates an instance of MKRSSFeed.
 
 @param aURL the URL of the feed you are requesting. Cannot be nil.
 
 @param delegate the MKRSSFeedDelegate. Set to nil if you are not using
 a delegate.
 
 @return MKRSSFeed instance
 
 @exception MKFeedParserNILURLException Exception is thrown if the aURL paramenter is nil.
 Exception is catchable.
*/
- (id)initWithURL:(NSString *)aURL delegate:(id<MKFeedParserDelegate>)theDelegate;

///----------------------------------------------
/// @name Preforming Requests
///----------------------------------------------

/**
 Starts the request for data from the provided URL, and returns the results
 through the MKRSSFeedDelegate.
*/
- (void)request;

/**
 Starts the request for data from the provided URL, and returns the results
 through the MKRequestComplete block.
 
 @param block the code block to run when the request is complete.
*/
- (void)requestWithCompletionBlock:(MKRequestComplete)block;

///-----------------------------------------------
/// @name Feed Information
///-----------------------------------------------

/** The URL address of the feed. */
@property (nonatomic, readonly) NSString *url;

/** 
 The number of items the request should return.  Default is 15.
 
 This property must be set before a request or requestWithCompletionBlock: method
 is called.
*/
@property (nonatomic, assign) NSInteger numberOfItems;

///-----------------------------------------------
/// @name Archiving
///-----------------------------------------------

/** Set to `YES` if you want the results to be archived to the disk. Default is `NO` */
@property (nonatomic, assign) BOOL archiveResults;

/** The path to write/sync the parsed results to. */
@property (nonatomic, copy) NSString *archivePath;

/** The iCloud file URL to sync the parsed results to. */
@property (nonatomic, retain) NSURL *cloudURL;

/** 
 Tells the parser if it should archive the results and retuns the results throught the
 successful block.
 
 @param path the path to write/sync the parsed results to.
 
 @param sucessul the block to call when the sync is complete. Block will pass of three
 `MKArchiverSyncResults`:
 
 * `MKArchiverSyncIncomplete` : sync was successful, but there may be a gap in the items.
 * `MKArchiverSyncComplete` : sync was successful.
 * `MKArchiverSyncFailed` : sync was not successful.
*/
- (void)setArchiveResultsToPath:(NSString *)path successful:(MKArchiveSuccessful)successful;

/**
 Tells the parser to sync the results with the given iCloud file URL.
 
 @param URL an iCloud file URL to sync with
 
 @param sucessul the block to call when the sync is complete. Block will pass of three
 `MKArchiverSyncResults`:
 
 * `MKArchiverSyncIncomplete` : sync was successful, but there may be a gap in the items.
 * `MKArchiverSyncComplete` : sync was successful.
 * `MKArchiverSyncFailed` : sync was not successful.
 
 @warning *Note* MKFeedParser assumes that all the require iCloud use checks have been done prior
 to requesting data.  It does not check for iCloud avialbility or the existance of a file at the 
 given file URL.
*/
- (void)setArchiveResultsToCloudURL:(NSURL *)URL successful:(MKArchiveSuccessful)successful;

///-----------------------------------------------
/// @name Delegate
///-----------------------------------------------

/** The MKRSSFeedDelegate */
@property (assign) id<MKFeedParserDelegate> delegate;

///-----------------------------------------------
/// @name Blocks
///-----------------------------------------------

/** The request complete block. This block is ran when a request is finished. */
@property (nonatomic, copy) MKRequestComplete requestCompleteBlock;

/** The archive complete block. This block is ran when a archive is finished. */
@property (nonatomic, copy) MKArchiveSuccessful archiveSuccessBlock;

///----------------------------------------------
/// @name Deprecated
///----------------------------------------------

/** DEPRECATED v1.0 */
@property (nonatomic, readonly) MKFeedContentType contentType MK_DEPRECATED_1_0;

/** DEPRECATED v1.0 */
@property (nonatomic, assign) MKFeedSourceType sourceType; //MK_DEPRECATED_1_0;

@end

/// Google Feed API JSON Elements 
NSString *MKGoogleJSONTitle MK_VISIBLE_ATTRIBUTE;
NSString *MKGoogleJSONLink MK_VISIBLE_ATTRIBUTE;
NSString *MKGoogleJSONContentSnippet MK_VISIBLE_ATTRIBUTE;
NSString *MKGoogleJSONAuthor MK_VISIBLE_ATTRIBUTE;

/**-----------------------------------------------------------------------------------
 *Overview*
 
 The MKRSSFeedDelegate provides methods to observe the actions taken by the MKRSSFeed class.
------------------------------------------------------------------------------------*/
@protocol MKFeedParserDelegate <NSObject>

@optional

///-----------------------------------------------
/// @name Handeling Data
///-----------------------------------------------

/**
 Called when a request is finished.
 
 @param feed the MKRSSFeed instance that started the request.
 
 @param data the parsed RSS feed data.
*/
- (void)feed:(MKFeedParser *)feed didReturnData:(NSArray *)data;

///-----------------------------------------------
/// @name Archiving Methods
///-----------------------------------------------

/**
 Called when a archive is finished.
 
 @param feed the instance of MKFeedParser making the call to the delegate
 
 @param successful `YES` if the archive was successful, `NO` if not.
*/
- (void)feed:(MKFeedParser *)feed didArchiveResuslts:(BOOL)successful;

/**
 Called when an archive changes it status
 
 @param feed the feed instance that is archiving
 
 @param results the stats of the archive process
*/
- (void)feed:(MKFeedParser *)feed changedToArchiveStatus:(MKArchiverSyncResults)results;

///------------------------------------------------
/// @name Observing Progress
///------------------------------------------------

/**
 Called a request starts
 
 @param feed the instance starting the request
*/
- (void)requestStartedForFeed:(MKFeedParser *)feed;

/**
 Called when a request is complete
 
 @param feed the instance that fininshed the request
*/
- (void)requestCompleteForFeed:(MKFeedParser *)feed;

@end



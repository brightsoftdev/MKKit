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

typedef void (^MKRequestComplete)(NSArray *feedInfo, NSError *error);

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
 
 *Requied Framworks*
 
 * Foundation
 
 *Requred Classes*
 
 * MKFeedItem
 
 *Required Protocols*
 
 * MKFeedParserDelegate
----------------------------------------------------------------------------------*/

@interface MKFeedParser : NSObject <NSXMLParserDelegate> {
	NSString *mUrl;
	id delegate;
    MKRequestComplete mRequestCompleteBlock;
	
@private
	NSMutableURLRequest *request; 
	NSMutableData *requestData;
    NSURLConnection *theConnection;
    NSURLCache *requestCache;

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
/// @name Delegate
///-----------------------------------------------

/** The MKRSSFeedDelegate */
@property (assign) id<MKFeedParserDelegate> delegate;

///-----------------------------------------------
/// @name Blocks
///-----------------------------------------------

/** The request complete block. This block is ran when a request is finished. */
@property (nonatomic, copy) MKRequestComplete requestCompleteBlock;

///----------------------------------------------
/// @name Deprecated
///----------------------------------------------

/** DEPRECATED v1.0 */
@property (nonatomic, readonly) MKFeedContentType contentType MK_DEPRECATED_1_0;

/** DEPRECATED v1.0 */
@property (nonatomic, assign) MKFeedSourceType sourceType; //MK_DEPRECATED_1_0;

@end

/// Google Feed API JSON Elements 
/// NEW
NSString *MKGoogleJSONTitle MK_VISIBLE_ATTRIBUTE;
NSString *MKGoogleJSONLink MK_VISIBLE_ATTRIBUTE;
NSString *MKGoogleJSONContentSnippet MK_VISIBLE_ATTRIBUTE;
NSString *MKGoogleJSONAuthor MK_VISIBLE_ATTRIBUTE;

/**-----------------------------------------------------------------------------------
 *Overview*
 
 The MKRSSFeedDelegate provides methods to observe the actions taken by the MKRSSFeed class.
------------------------------------------------------------------------------------*/
@protocol MKFeedParserDelegate <NSObject>

///-----------------------------------------------
/// @name Required Methods
///-----------------------------------------------

/**
 Called when a request is finished.
 
 @param feed the MKRSSFeed instance that started the request.
 
 @param data the parsed RSS feed data.
*/
- (void)feed:(MKFeedParser *)feed didReturnData:(NSArray *)data;

@end



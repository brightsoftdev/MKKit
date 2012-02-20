//
//  MKFeedItem.h
//  MKKit
//
//  Created by Matthew King on 11/26/11.
//  Copyright (c) 2011 Matt King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKFeedParser.h"

/**-------------------------------------------------------------------------
 *Overview*
 
 MKFeedItem class holds data from an RSS or ATOM feed. Each instance holds the
 the data of one feed item. This is default class for accessing data from a 
 MKFeedParser instace.  It can also be used independently.
 
 *Key Value Coding*
 
 MKFeedItem instance are Key Value Coded for the itemTitle, itemContent, and 
 itemAuthor properties to support seaches with NSPredicate instances. 
 
 *Required Frameworks*
 
 * Foundation
 
 *Required Classes*
 
 * MKFeedParser
--------------------------------------------------------------------------*/

@interface MKFeedItem : NSObject <NSCoding> {
@private 
    MKFeedSourceType mContentType;
    NSString *mItemTitle;
    NSString *mItemContent;
    NSString *mItemLinkURL;
    NSString *mItemAuthor;
    BOOL mItemRead;
}

///---------------------------------------------
/// @name Adding Content
///---------------------------------------------

/**
 Adds a value for a feed element.
 
 @param value the value of the element. This will typically
 be a NSString.
 
 @param element the name of the feed element.
*/
- (void)addValue:(id)value forElement:(NSString *)element;

///---------------------------------------------
/// @name Accessing Content
///---------------------------------------------

/** The tilte of the feed item. This property is KVC compatible. */
@property (nonatomic, readonly) NSString *itemTitle;

/** The content of the feed item. This property is KVC compatible. */
@property (nonatomic, readonly) NSString *itemContent;

/** The URL link of the feed item. */
@property (nonatomic, readonly) NSString *itemLinkURL;

/** The author of the feed item. This property is KVC compatible. */
@property (nonatomic, readonly) NSString *itemAuthor;

/** Identifies if the item has been read or not. Default is `NO`. */
@property (nonatomic, assign) BOOL itemRead;

///----------------------------------------------
/// @name Deprecated
///----------------------------------------------

/** DEPRECATED v1.0 */
- (id)initWithType:(MKFeedSourceType)type MK_DEPRECATED_1_0;

/** DEPRECATED v1.0 */
@property (nonatomic, readonly) MKFeedSourceType contentType MK_DEPRECATED_1_0;

/** DEPRECATED v1.0 */
@property (nonatomic, readonly) NSString *itemGUID; //MK_DEPRECATED_1_0;

/** DEPRECATED v1.0 */
@property (nonatomic, readonly) NSDate *itemPubDate; //MK_DEPRECATED_1_0;

/** DEPRECATED v1.0 */
@property (nonatomic, readonly) NSString *itemOriginalLinkURL; //MK_DEPRECATED_1_0;

@end

NSString *MKFeedItemTitle MK_VISIBLE_ATTRIBUTE;
NSString *MKFeedItemContent MK_VISIBLE_ATTRIBUTE;
NSString *MKFeedItemLinkURL MK_VISIBLE_ATTRIBUTE;
NSString *MKFeedItemAuthor MK_VISIBLE_ATTRIBUTE;
NSString *MKFeedItemRead MK_VISIBLE_ATTRIBUTE;
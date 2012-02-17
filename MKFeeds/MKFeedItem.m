//
//  MKFeedItem.m
//  MKKit
//
//  Created by Matthew King on 11/26/11.
//  Copyright (c) 2011 Matt King. All rights reserved.
//

#import "MKFeedItem.h"
#import "NSString+MKFeedParser.h"

@interface MKFeedItem ()

- (void)setKeys;

@end

@implementation MKFeedItem

@dynamic contentType, itemTitle, itemContent, itemLinkURL, itemOriginalLinkURL, itemAuthor, itemGUID, itemPubDate, itemRead;

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self setKeys];
        
        mItemTitle = [[aDecoder decodeObjectForKey:MKFeedItemTitle] copy];
        mItemContent = [[aDecoder decodeObjectForKey:MKFeedItemContent] copy];
        mItemLinkURL = [[aDecoder decodeObjectForKey:MKFeedItemLinkURL] copy];
        mItemAuthor = [[aDecoder decodeObjectForKey:MKFeedItemAuthor] copy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:mItemTitle forKey:MKFeedItemTitle];
    [aCoder encodeObject:mItemContent forKey:MKFeedItemContent];
    [aCoder encodeObject:mItemLinkURL forKey:MKFeedItemLinkURL];
    [aCoder encodeObject:mItemAuthor forKey:MKFeedItemAuthor];
}

#pragma mark - Creatition

- (id)init {
    self = [super init];
    if (self) {
        [self setKeys];
    }
    return self;
}

- (id)initWithType:(MKFeedSourceType)type {
    return nil;
}

- (void)setKeys {
    MKFeedItemTitle = @"MKFeedItemTitle";
    MKFeedItemContent = @"MKFeedItemContent";
    MKFeedItemLinkURL = @"MKFeedItemLinkURL";
    MKFeedItemAuthor = @"MKFeedItemAuthor";
}

#pragma mark - Memory Managment

- (void)dealloc {
    [mItemTitle release];
    [mItemContent release];
    [mItemLinkURL release];
    [mItemAuthor release];
    [super dealloc];
}

#pragma mark - Setting Content

- (void)addValue:(id)value forElement:(NSString *)element {
    if ([value isKindOfClass:[NSString class]] && ![element isEqualToString:MKFeedItemLinkURL]) {
        NSString *stringValue = (NSString *)value;
        stringValue = [stringValue stringByStrippingHTML];
        stringValue = [stringValue stringByDecodingHTMLEntities];
        stringValue = [stringValue stringByRemovingNewLinesAndWhitespace];
        
        if ([element isEqualToString:MKFeedItemTitle]) {
            mItemTitle = [stringValue copy];
        }
        else if ([element isEqualToString:MKFeedItemContent]) {
            mItemContent = [stringValue copy];
        }
        else if ([element isEqualToString:MKFeedItemAuthor]) {
            mItemAuthor = [stringValue copy];
        }
    }
    else if ([element isEqualToString:MKFeedItemLinkURL]) {
        mItemLinkURL = [(NSString *)value copy];
    }
}

#pragma mark - Accessor Methods
#pragma mark Getters

- (NSString *)itemTitle {
    return mItemTitle;
}

- (NSString *)itemContent {
    return mItemContent;
}

- (NSString *)itemLinkURL {
    return mItemLinkURL;
}

- (NSString *)itemAuthor {
    return mItemAuthor;
}

#pragma mark - KVC
#pragma mark Setters

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"itemTitle"]) {
        mItemTitle = [(NSString *)value copy];
    }
    if ([key isEqualToString:@"itemContent"]) {
        mItemContent = [(NSString *)value copy];
    }
    if ([key isEqualToString:@"itemAuthor"]) {
        mItemAuthor = [(NSString *)value copy];
    }
}

#pragma mark Getters

- (id)valueForKey:(NSString *)key {
    if ([key isEqualToString:@"itemTitle"]) {
        return mItemTitle;
    }
    if ([key isEqualToString:@"itemContent"]) {
        return mItemContent;
    }
    if ([key isEqualToString:@"itemAuthor"]) {
        return mItemAuthor;
    }
    return nil;
}

#pragma mark - Deprecation

- (MKFeedSourceType)contentType {
    return -1;
}
- (NSString *)itemOriginalLinkURL {
    return nil;
}

- (NSString *)itemGUID {
    return nil;
}

- (NSDate *)itemPubDate {
    return nil;
}

@end

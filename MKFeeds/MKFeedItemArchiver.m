//
//  MKFeedItemArchiver.m
//  MKKit
//
//  Created by Matthew King on 2/17/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKFeedItemArchiver.h"
#import "MKFeedItem.h"

@interface MKFeedItemArchiver () 

- (NSMutableArray *)currentItemsFromPath:(NSString *)path;
- (NSMutableArray *)decodedItemsFromArray:(NSArray *)array;
- (NSData *)encodedItem:(MKFeedItem *)item;

@end

@implementation MKFeedItemArchiver

#pragma mark - Creation

- (id)initWithItems:(NSArray *)items {
    self = [super init];
    if (self) {
        mItems = [[[items reverseObjectEnumerator] allObjects] retain];
    }
    return self;
}

#pragma mark - Memory

- (void)dealloc {
    [mItems release];
    [super dealloc];
}

#pragma mark - Archiving

- (void)archiveToFileAtPath:(NSString *)path completion:(void (^) (BOOL finished))completion {
    NSMutableArray *currentItems = [[NSMutableArray alloc] initWithCapacity:0];
    
    mItems = [[[mItems reverseObjectEnumerator] allObjects] retain];
    
    for (MKFeedItem *item in mItems) {
        NSMutableData *data = [NSMutableData data];
        
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [item encodeWithCoder:archiver];
        [archiver finishEncoding];
        
        [currentItems addObject:data];
    }
    
    BOOL complete = [currentItems writeToFile:path atomically:YES];
    
    [currentItems release];
    completion(complete);
}

- (void)syncWithArchiveFileAtPath:(NSString *)path completion:(void (^)(BOOL))completion {
    NSMutableArray *currentItems = [self currentItemsFromPath:path];
    
    if ([currentItems count] == 0) {
        BOOL complete = [self addAllItemsToPath:path];
        completion(complete);
        return;
    }
    
    else {
        NSMutableArray *decodedList = [self decodedItemsFromArray:currentItems];
        NSString *attribute = [NSString stringWithString:@"itemLinkURL"];
        
        NSInteger newItems = 0;
        
        for (MKFeedItem *item in mItems) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K == %@)", attribute, item.itemLinkURL];
            NSArray *filteredArray = [decodedList filteredArrayUsingPredicate:predicate];
            
            if ([filteredArray count] == 0) {
                NSData *data = [self encodedItem:item];
                [currentItems insertObject:data atIndex:0];
                
                newItems = (newItems + 1);
            }
        }
        
        if (newItems != 0) {
            BOOL complete = [currentItems writeToFile:path atomically:YES];
            completion(complete);
            return;
        }
    }
    completion(YES);
}

#pragma mark - Helper

- (NSMutableArray *)currentItemsFromPath:(NSString *)path {
    NSMutableArray *currentItems = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        currentItems = [[[NSMutableArray alloc] initWithContentsOfFile:path] autorelease];
    }
    else {
        currentItems = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    }
    
    return currentItems;
}

- (BOOL)addAllItemsToPath:(NSString *)path {
    NSMutableArray *currentItems = [self currentItemsFromPath:path];
    
    mItems = [[[mItems reverseObjectEnumerator] allObjects] retain];
    
    for (MKFeedItem *item in mItems) {
        NSData *data = [self encodedItem:item];
        [currentItems addObject:data];
    }
    
    BOOL complete = [currentItems writeToFile:path atomically:YES];
        
    return complete;
}

#pragma mark - Encoding

- (NSData *)encodedItem:(MKFeedItem *)item {
    NSMutableData *data = [NSMutableData data];
    
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [item encodeWithCoder:archiver];
    [archiver finishEncoding];
    
    return data;
}

#pragma mark - Decoding

- (NSMutableArray *)decodedItemsFromArray:(NSArray *)array {
    NSMutableArray *rtnArray = [NSMutableArray arrayWithCapacity:0];
    
    for (NSData *data in array) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        
        MKFeedItem *item = [[MKFeedItem alloc] initWithCoder:unarchiver];
        [unarchiver finishDecoding];
        [rtnArray addObject:item];
        
        [item release];
        [unarchiver release];
    }
    
    return rtnArray;
}

@end

//
//  MKFeedItemArchiver.m
//  MKKit
//
//  Created by Matthew King on 2/17/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKFeedItem.h"

#import <dispatch/dispatch.h>

//---------------------------------------------------------------
// Interfaces
//---------------------------------------------------------------

@interface MKFeedItemArchiver () 

- (NSMutableArray *)currentItemsFromPath:(NSString *)path;
- (NSMutableArray *)decodedItemsFromArray:(NSArray *)array;
- (NSData *)encodedItem:(MKFeedItem *)item;

@end

//---------------------------------------------------------------
// Implementation
//---------------------------------------------------------------

@implementation MKFeedItemArchiver

#pragma mark - Creation

//---------------------------------------------------------------
// Creation
//---------------------------------------------------------------

- (id)initWithItems:(NSArray *)items {
    self = [super init];
    if (self) {
        mItems = [[[items reverseObjectEnumerator] allObjects] retain];
    }
    return self;
}

#pragma mark - Memory

//---------------------------------------------------------------
// Memory
//---------------------------------------------------------------

- (void)dealloc {
    [mItems release];
    [super dealloc];
}

#pragma mark - Archiving

//---------------------------------------------------------------
// File Archiving/Syncing
//---------------------------------------------------------------

- (void)archiveToFileAtPath:(NSString *)path completion:(void (^) (BOOL finished))completion {
    NSMutableArray *currentItems = [[NSMutableArray alloc] initWithCapacity:0];
    
    mItems = [[[mItems reverseObjectEnumerator] allObjects] retain];
    
    for (MKFeedItem *item in mItems) {
        NSMutableData *data = [NSMutableData data];
        
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [item encodeWithCoder:archiver];
        [archiver finishEncoding];
        
        [currentItems addObject:data];
        [archiver release];
    }
    
    BOOL complete = [currentItems writeToFile:path atomically:YES];
    
    [currentItems release];
    completion(complete);
}

#pragma mark - Sync

- (void)syncWithArchiveFileAtPath:(NSString *)path completion:(void (^)(MKArchiverSyncResults syncResults))completion {
    NSMutableArray *currentItems = [self currentItemsFromPath:path];
    
    if ([currentItems count] == 0) {
        BOOL complete = [self addAllItemsToPath:path];
        if (complete) {
            completion(MKArchiverSyncComplete);
            return;
        }
        else {
            completion(MKArchiverSyncFailed);
            return;
        }
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
            if (newItems == [mItems count]) {
                completion(MKArchiverSyncIncomplete);
            }
            else {
                BOOL complete = [currentItems writeToFile:path atomically:YES];
                if (complete) {
                    completion(MKArchiverSyncComplete);
                    return;
                }
                else {
                    completion(MKArchiverSyncFailed);
                    return;
                }
            }
        }
    }
}

//---------------------------------------------------------------
// Cloud Archiving/Scyncing
//---------------------------------------------------------------

#if MKKIT_AVAILABLE_TO_MKFEEDS

- (void)syncWithCloudFileNamed:(NSString *)name completion:(void (^)(MKArchiverSyncResults))completion {
    __block NSMutableArray *currentItems = nil;
    
    MKCloud *cloudManager = [MKCloud cloudManager];
        
    [cloudManager openDocumentNamed:name content: ^ (id content) {
        if (content) {
            MKDocument *document = [cloudManager documentNamed:name];
            NSData *documentContent = (NSData *)content;
            
            if ([documentContent length] == 0) {
                mItems = [[[mItems reverseObjectEnumerator] allObjects] retain];
                currentItems = [[[NSMutableArray alloc] initWithArray:mItems] autorelease];
            }
            else {
                currentItems = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)content];
                MK_S_LOG(@"Current Feed Items: %i", [currentItems count]);
                MK_S_LOG(@"Returned Feed Items: %i", [mItems count]);
                
                if ([currentItems count] == 0) {
                    mItems = [[[mItems reverseObjectEnumerator] allObjects] retain];
                    currentItems = [[[NSMutableArray alloc] initWithArray:mItems] autorelease];
                }
                else {
                    NSString *attribute = [NSString stringWithString:@"itemLinkURL"];
                    
                    NSInteger newItems = 0;
                    
                    for (MKFeedItem *item in mItems) {
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K == %@)", attribute, item.itemLinkURL];
                        NSArray *filteredArray = [currentItems filteredArrayUsingPredicate:predicate];
                        
                        if ([filteredArray count] == 0) {
                            [currentItems insertObject:item atIndex:0];
                            
                            newItems = (newItems + 1);
                        }
                    }
                    
                    MK_S_LOG(@"New Feed Items: %i", newItems);
                    
                    if (newItems != 0) {
                        if (newItems == [mItems count]) {
                            completion(MKArchiverSyncIncomplete);
                            return;
                        }
                    }
                }
            }
            document.content = [NSKeyedArchiver archivedDataWithRootObject:currentItems];
            [cloudManager saveDocumentNamed:name successful: ^ (BOOL successful) {
                if (successful) {
                    completion(MKArchiverSyncComplete);
                    return;
                }
                else {
                    completion(MKArchiverSyncFailed);
                    return;
                }
            }];
        }
        else {
            
            completion(MKArchiverSyncFailed);
            return;
        }
    }];
}
    
#endif

//---------------------------------------------------------------
// Data Helpers
//---------------------------------------------------------------

#pragma mark - Helpers
#pragma mark Getting Data Files

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

#pragma mark Save Data Files

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

//---------------------------------------------------------------
// Encoding/Decoding
//---------------------------------------------------------------

- (NSData *)encodedItem:(MKFeedItem *)item {
    NSMutableData *data = [NSMutableData data];
    
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [item encodeWithCoder:archiver];
    [archiver finishEncoding];
    
    [archiver release];
    
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

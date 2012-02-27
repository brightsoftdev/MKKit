//
//  MKFeedItemArchiver.m
//  MKKit
//
//  Created by Matthew King on 2/17/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKFeedItemArchiver.h"
#import "MKFeedItem.h"

#pragma mark - Cloud Document

@interface MKFeedItemDocument : UIDocument 

@property (nonatomic, retain) NSMutableArray *fileData;
    
@end

#pragma mark - Archiver

@interface MKFeedItemArchiver () 

- (NSMutableArray *)currentItemsFromPath:(NSString *)path;
- (NSMutableArray *)cloudItemsFromURL:(NSURL *)URL;
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
//#warning : sync Test Logs        
        //NSLog(@"Request Items = %i", [mItems count]);
        //NSLog(@"New Items = %i", newItems);
        
        if (newItems != 0) {
            if (newItems == [mItems count]) {
                NSLog(@"Max Fill");
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

- (void)syncWithCloudFileAtURL:(NSURL *)URL completion:(void (^)(MKArchiverSyncResults))completion {
    NSMutableArray *currentItems = [self cloudItemsFromURL:URL];
    
    if ([currentItems count] == 0) {
        BOOL complete = [self addAllItemsToCloudURL:URL];
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
//#warning : sync Test Logs        
        //NSLog(@"Request Items = %i", [mItems count]);
        //NSLog(@"New Items = %i", newItems);
        
        if (newItems != 0) {
            if (newItems == [mItems count]) {
                NSLog(@"Max Fill");
                completion(MKArchiverSyncIncomplete);
            }
            else {
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:currentItems];
                BOOL complete = [data writeToURL:URL atomically:YES];
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

- (NSMutableArray *)cloudItemsFromURL:(NSURL *)URL {
    NSData *data = [NSData dataWithContentsOfURL:URL];
    NSMutableArray *rtnArray = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return rtnArray;
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

- (BOOL)addAllItemsToCloudURL:(NSURL *)URL {
    NSMutableArray *currentItems = [self cloudItemsFromURL:URL];
    
    mItems = [[[mItems reverseObjectEnumerator] allObjects] retain];
    
    for (MKFeedItem *item in mItems) {
        [currentItems addObject:item];
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mItems];
    
    BOOL complete = [data writeToURL:URL atomically:YES];
    
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

#pragma mark - Cloud Document

@implementation MKFeedItemDocument

@synthesize fileData;

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError {
    self.fileData = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:contents];
    
    return YES;
}

- (id)contentsForType:(NSString *)typeName error:(NSError **)outError {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.fileData];
    return data;
}

@end
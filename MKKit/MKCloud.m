//
//  MKCloud.m
//  MKKit
//
//  Created by Matthew King on 2/25/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKCloud.h"

typedef void (^MKCloudLoadedFileHandler)(NSURL *fielURL);

//---------------------------------------------------------------
// Interfaces
//---------------------------------------------------------------

@interface MKCloud ()

- (void)queryDidFinish:(NSNotification *)notification;

@property (nonatomic, copy) MKCloudLoadedFileHandler loadFileHandler;

@end

//---------------------------------------------------------------
// Implementation
//---------------------------------------------------------------

@implementation MKCloud

@synthesize loadFileHandler;

#pragma mark - Creating 

//---------------------------------------------------------------
// Creation
//---------------------------------------------------------------

+ (id)cloudManager {
    return [[[[self class] alloc] init] autorelease];
}

#pragma mark - Availability

//---------------------------------------------------------------
// Finding Availability
//---------------------------------------------------------------

+ (BOOL)iCloudIsAvailable {
    BOOL availible = NO;
    
    NSURL *ubiq = [[NSFileManager defaultManager] 
                   URLForUbiquityContainerIdentifier:nil];
    if (ubiq) {
        availible = YES;
    } 
    
    return availible;
}

#pragma mark - File Operations

//---------------------------------------------------------------
// File Operations
//---------------------------------------------------------------

#pragma mark Load File

- (void)urlForFileNamed:(NSString *)name result:(MKCloudLoadedFileHandler)result {
    self.loadFileHandler = result;
    
    mQuery = [[NSMetadataQuery alloc] init];
    [mQuery setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSMetadataItemFSNameKey, name];
    [mQuery setPredicate:predicate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryDidFinish:) name:NSMetadataQueryDidFinishGatheringNotification object:mQuery];

    [mQuery startQuery];
    
    [self retain];
}

#pragma mark Remove File

- (void)removeCloudFileNamed:(NSString *)name directory:(NSString *)directory successful:(void (^)(BOOL))successful {
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSURL *ubiq = [defaultManager URLForUbiquityContainerIdentifier:nil];
    NSURL *ubiqPackage = nil;
    
    if (directory) {
        ubiqPackage = [[ubiq URLByAppendingPathComponent:directory] URLByAppendingPathComponent:name];
    }
    else {
        ubiqPackage = [ubiq URLByAppendingPathComponent:name];
    }
    
    NSError *removeError;
    [defaultManager removeItemAtURL:ubiqPackage error:&removeError];
    
    if (removeError) {
        successful(NO);
    }
    else {
        successful(YES);
    }
}

#pragma mark - Notifications

//---------------------------------------------------------------
// Notifications
//---------------------------------------------------------------

#pragma mark Query Results

- (void)queryDidFinish:(NSNotification *)notification {
    NSMetadataQuery *query = (NSMetadataQuery *)[notification object];
    [query disableUpdates];
    [query stopQuery];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:query];
    
    if ([query resultCount] !=0) {
        NSMetadataItem *item = [query resultAtIndex:0];
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        
        loadFileHandler(url);
    }
    else {
        loadFileHandler(nil);
    }
    
    [mQuery release]; mQuery = nil;
    
    [self release];
}

@end

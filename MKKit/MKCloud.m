//
//  MKCloud.m
//  MKKit
//
//  Created by Matthew King on 2/25/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKCloud.h"

@interface MKCloud ()

- (void)queryDidFinish:(NSNotification *)notification;

@end

@implementation MKCloud

@synthesize loadFileHandler;

#pragma mark - Creating 

+ (id)cloudManager {
    return [[[[self class] alloc] init] autorelease];
}

#pragma mark - Availability

+ (BOOL)iCloudIsAvailable {
    BOOL availible = NO;
    
    NSURL *ubiq = [[NSFileManager defaultManager] 
                   URLForUbiquityContainerIdentifier:nil];
    if (ubiq) {
        availible = YES;
    } 
    
    return availible;
}

#pragma mark - File URL

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

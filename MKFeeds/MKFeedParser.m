//
//  MKRSSFeed.m
//  MKKit
//
//  Created by Matthew King on 8/13/10.
//  Copyright 2010-2012 Matt King. All rights reserved.
//

#import "MKFeedParser.h"
#import "MKFeedItem.h"
#import "MKFeedItemArchiver.h"

#define MK_FEED_BASE_URL        @"https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&scoring=h"

typedef enum {
    MKFeedParserOperation,
    MKFeedArchiveOperation,
} MKFeedOperationType;

#pragma mark - JSON Parse Operation

@interface MKFeedParseOperation : NSOperation {
@private
    NSData *JSONData;
    NSArray *items;
    id target;
    SEL mainThreadCallBack;
    
    MKFeedOperationType operationType;
}

- (id)initWithData:(NSData *)data target:(id)target mainThreadCallBack:(SEL)callBack;
- (id)initWithItems:(NSArray *)items target:(id)target mainThreadCallBack:(SEL)callBack;

- (void)JSONParseWithData:(NSData *)data result:(void (^)(id resultObject))result;

@property (nonatomic, assign) BOOL archive;
@property (nonatomic, assign) NSInteger fromIndex;

@property (nonatomic, copy) NSString *archivePath;
@property (nonatomic, retain) NSURL *archiveCloudURL;

@property (nonatomic, assign) MKFeedArchiveType archiveType;

@end

#pragma mark - MKFeedParser

typedef void (^MKRequestComplete)(NSArray *feedInfo, NSError *error);
typedef void (^MKArchiveSuccessful)(BOOL successful);

@interface MKFeedParser () 

- (void)parserResults:(id)results;
- (void)archiveComplete:(id)results;

@property (nonatomic, copy) MKRequestComplete requestCompleteBlock;
@property (nonatomic, copy) MKArchiveSuccessful archiveSuccessBlock;

@end

@implementation MKFeedParser

@synthesize url=mUrl, delegate, requestCompleteBlock=mRequestCompleteBlock, numberOfItems, archivePath, cloudURL, archiveResults, 
archiveSuccessBlock;

@dynamic sourceType, contentType;

- (id)initWithURL:(NSString *)aURL delegate:(id<MKFeedParserDelegate>)theDelegate {
	if (self = [super init]) {
        if (aURL == nil) {
            MKFeedParserNILURLException = @"MKFeedParserNILURLException";
            NSException *exception = [NSException exceptionWithName:MKFeedParserNILURLException reason:@"URL cannot be a nil value." userInfo:nil];
            @throw exception;
        }
		mUrl = [aURL copy];
		delegate = theDelegate;
        
        self.numberOfItems = 15;
	}
	return self; 
}

#pragma mark - Memory Management

-(void)dealloc {
    self.delegate = nil;
    self.requestCompleteBlock = nil;
    self.archivePath = nil;
    
    [mUrl release];
    
	[super dealloc];
}

#pragma mark - request

- (void)request {
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    
    NSString *num = [NSString stringWithFormat:@"&num=%i", self.numberOfItems];
    NSString *q = [NSString stringWithFormat:@"&q=%@", mUrl];
    NSString *requestURL = [NSString stringWithFormat:@"%@%@%@", MK_FEED_BASE_URL, num, q];
    
	urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];
    
	theConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	
	if (theConnection) {
		requestData = [[NSMutableData data] retain];
	} 
    
    if ([self.delegate respondsToSelector:@selector(requestStartedForFeed:)]) {
        [self.delegate requestStartedForFeed:self];
    }
}

- (void)requestWithCompletionBlock:(MKRequestComplete)block {
    self.requestCompleteBlock = block;
    MKRSSFeedTags.usesCompletionBlock = YES;
    [self request];
}

#pragma mark -
#pragma mark Connection Delegate


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [requestData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [theConnection release];
	[requestData release];
	
	[urlRequest release];
    
    if (MKRSSFeedTags.usesCompletionBlock) {
        self.requestCompleteBlock(nil, error);
    }
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    ////////////////////////////////////////////////////////////
    // UNCOMMENT THESE LINES TO POST THE FEED DATA IN THE LOG //
    ////////////////////////////////////////////////////////////
    
	//NSString *data = [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding];
	//NSLog(@"%@", data);
    
    NSOperationQueue *parseQueue = [NSOperationQueue mainQueue];
	
    MKFeedParseOperation *parseOpperation = [[MKFeedParseOperation alloc] initWithData:requestData target:self mainThreadCallBack:@selector(parserResults:)];
    [parseQueue addOperation:parseOpperation];
    [parseOpperation release];
    
	[theConnection release];
	[requestData release];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
	[urlRequest release];
    
    if ([self.delegate respondsToSelector:@selector(requestCompleteForFeed:)]) {
        [self.delegate requestCompleteForFeed:self];
    }
}

#pragma mark - Parse Results

- (void)parserResults:(id)results {
    if ([results isKindOfClass:[NSMutableArray class]]) {
        if (MKRSSFeedTags.usesCompletionBlock) {
            self.requestCompleteBlock(results, nil);
        }
        else {
            [delegate feed:self didReturnData:results];
        }
        
        if (self.archiveResults) {
            MKFeedParseOperation *operation = [[MKFeedParseOperation alloc] initWithItems:results target:self mainThreadCallBack:@selector(archiveComplete:)];
            operation.archiveType = mArchiveType;

            if (mArchiveType == MKFeedArchiveWithFile) {
                operation.archivePath = self.archivePath;
            }
            else {
                operation.archiveCloudURL = self.cloudURL;
            }

            
            NSOperationQueue *operationQueue = [NSOperationQueue mainQueue];
            [operationQueue addOperation:operation];
            
            [operation release];
        }
    }
}

#pragma mark - Archiving

- (void)setArchiveResultsToPath:(NSString *)path successful:(MKArchiveSuccessful)successful {
    mArchiveType = MKFeedArchiveWithFile;
    
    self.archiveResults = YES;
    self.archivePath = path;
    self.archiveSuccessBlock = successful;
}

- (void)setArchiveResultsToCloudURL:(NSURL *)URL successful:(MKArchiveSuccessful)successful {
    mArchiveType = MKFeedArchiveWithCloud;
    
    self.archiveResults = YES;
    self.cloudURL = URL;
    self.archiveSuccessBlock = successful;
}

- (void)archiveComplete:(id)results {
    BOOL successful = YES;
        
    if ([results isKindOfClass:[NSError class]]) {
        successful = NO;
        
        NSError *archiveError = (NSError *)results;
        
        if ([archiveError code] == kMKFeedItemArchiveSyncIncompleteCode) {
            self.numberOfItems = (self.numberOfItems + 25);
            [self request];
            
            if ([self.delegate respondsToSelector:@selector(feed:changedToArchiveStatus:)]) {
                [self.delegate feed:self changedToArchiveStatus:MKArchiverSyncIncomplete];
            }
        }
        else if ([archiveError code] == kMKFeedItemArchiveErrorCode) {
            if ([self.delegate respondsToSelector:@selector(feed:changedToArchiveStatus:)]) {
                [self.delegate feed:self changedToArchiveStatus:MKArchiverSyncFailed];
            }
        }
    }
    
    if (self.archiveSuccessBlock) {
        self.archiveSuccessBlock(successful);
    }
    if ([self.delegate respondsToSelector:@selector(feed:didArchiveResuslts:)]) {
        [self.delegate feed:self didArchiveResuslts:successful];
    }
    
    if (successful) {
        if ([self.delegate respondsToSelector:@selector(feed:changedToArchiveStatus:)]) {
            [self.delegate feed:self changedToArchiveStatus:MKArchiverSyncComplete];
        }
    }
}

#pragma mark - Deprecations

- (void)setSourceType:(MKFeedSourceType)type {
}

- (MKFeedContentType)contentType {
    return 0;
}

- (MKFeedSourceType)sourceType {
    return 0;
}

@end

#pragma mark - JSON Parse Operation

@implementation MKFeedParseOperation

@synthesize archive, fromIndex, archivePath, archiveCloudURL, archiveType;

#pragma mark - Creation

- (id)initWithData:(NSData *)data target:(id)_target mainThreadCallBack:(SEL)callBack {
    self = [super init];
    if (self) {
        JSONData = [data retain];
        target = [_target retain];
        mainThreadCallBack = callBack;
        
        operationType = MKFeedParserOperation;
        
        MKGoogleJSONTitle = @"title";
        MKGoogleJSONLink = @"link";
        MKGoogleJSONContentSnippet = @"contentSnippet";
        MKGoogleJSONAuthor = @"author";
    }
    return self;
}

- (id)initWithItems:(NSArray *)_items target:(id)_target mainThreadCallBack:(SEL)callBack {
    self = [super init];
    if (self) {
        items = [_items retain];
        target = [_target retain];
        mainThreadCallBack = callBack;
        
        operationType = MKFeedArchiveOperation;
    }
    return self;
}

#pragma mark - Memory

- (void)dealloc {
    [items release];
    [JSONData release];
    [target release];
    
    mainThreadCallBack = nil;
    self.archiveCloudURL = nil;
    self.archivePath = nil;
    
    [super dealloc];
}

#pragma mark - Main

- (void)main {
    if (operationType == MKFeedParserOperation) {
        [self JSONParseWithData:JSONData result: ^ (id resultObject) {
            [target performSelectorOnMainThread:mainThreadCallBack withObject:resultObject waitUntilDone:YES];
        }];
    }
    
    else if (operationType == MKFeedArchiveOperation) {
        MKFeedItemArchiver *archiver = [[MKFeedItemArchiver alloc] initWithItems:items];

        if (self.archiveType == MKFeedArchiveWithFile) {
            [archiver syncWithArchiveFileAtPath:self.archivePath completion: ^ (MKArchiverSyncResults syncResults) {
                if (syncResults == MKArchiverSyncComplete) {
                    [target performSelectorOnMainThread:mainThreadCallBack withObject:nil waitUntilDone:YES];
                }
                else if (syncResults == MKArchiverSyncFailed) {
                    MKFeedItemArchiveError = @"MKFeedItemArchiveError";
                    NSError *error = [NSError errorWithDomain:MKFeedItemArchiveError code:kMKFeedItemArchiveErrorCode userInfo:nil];
                    
                    [target performSelectorOnMainThread:mainThreadCallBack withObject:error waitUntilDone:YES];
                }
                else if (syncResults == MKArchiverSyncIncomplete) {
                    MKFeedItemArchiveSyncIncompleteError = @"MKFeedItemArchiveSyncIncompleteError";
                    NSError *error = [NSError errorWithDomain:MKFeedItemArchiveSyncIncompleteError code:kMKFeedItemArchiveSyncIncompleteCode userInfo:nil];
                    
                    [target performSelectorOnMainThread:mainThreadCallBack withObject:error waitUntilDone:YES];
                }
            }];
        }
        else if (self.archiveType == MKFeedArchiveWithCloud) {
            [archiver syncWithCloudFileAtURL:self.archiveCloudURL completion: ^ (MKArchiverSyncResults syncResults) {
                if (syncResults == MKArchiverSyncComplete) {
                    [target performSelectorOnMainThread:mainThreadCallBack withObject:nil waitUntilDone:YES];
                }
                else if (syncResults == MKArchiverSyncFailed) {
                    MKFeedItemArchiveError = @"MKFeedItemArchiveError";
                    NSError *error = [NSError errorWithDomain:MKFeedItemArchiveError code:kMKFeedItemArchiveErrorCode userInfo:nil];
                    
                    [target performSelectorOnMainThread:mainThreadCallBack withObject:error waitUntilDone:YES];
                }
                else if (syncResults == MKArchiverSyncIncomplete) {
                    MKFeedItemArchiveSyncIncompleteError = @"MKFeedItemArchiveSyncIncompleteError";
                    NSError *error = [NSError errorWithDomain:MKFeedItemArchiveSyncIncompleteError code:kMKFeedItemArchiveSyncIncompleteCode userInfo:nil];
                    
                    [target performSelectorOnMainThread:mainThreadCallBack withObject:error waitUntilDone:YES];
                }
            }];
        }

        [archiver release];
    }
}

#pragma mark - Parse

- (void)JSONParseWithData:(NSData *)data result:(void (^)(id resultObject))result {
    NSError *error;
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSDictionary *responseDict = [dataDict objectForKey:@"responseData"];
    NSDictionary *feedDict = [responseDict objectForKey:@"feed"];
    
    NSMutableArray *rtnItems = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray *entrys = [feedDict objectForKey:@"entries"];
    
    for (NSDictionary *dict in entrys) {
        MKFeedItem *feedItem = [[MKFeedItem alloc] init];
        [feedItem addValue:[dict objectForKey:MKGoogleJSONTitle] forElement:MKFeedItemTitle];
        [feedItem addValue:[dict objectForKey:MKGoogleJSONLink] forElement:MKFeedItemLinkURL];
        [feedItem addValue:[dict objectForKey:MKGoogleJSONContentSnippet] forElement:MKFeedItemContent];
        [feedItem addValue:[dict objectForKey:MKGoogleJSONAuthor] forElement:MKFeedItemAuthor];
        
        [rtnItems addObject:feedItem];
        [feedItem release];
    }
    
    result(rtnItems);
    
    [rtnItems release];
}
@end
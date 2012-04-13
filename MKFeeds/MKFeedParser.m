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

//---------------------------------------------------------------
// Macros
//---------------------------------------------------------------

#define MK_FEED_BASE_URL        @"https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&scoring=h"

//---------------------------------------------------------------
// Type Deffinitions
//---------------------------------------------------------------

typedef enum {
    MKFeedParserOperation,
    MKFeedArchiveOperation,
} MKFeedOperationType;

typedef void (^MKRequestComplete)(NSArray *feedInfo, NSError *error);
typedef void (^MKArchiveSuccessful)(BOOL complete);

#pragma mark - JSON Parse Operation

//---------------------------------------------------------------
// Interfaces
//---------------------------------------------------------------

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

@property (nonatomic, assign) MKFeedArchiveType archiveType;

#if MKKIT_AVAILABLE_TO_MKFEEDS
@property (nonatomic, retain) NSString *cloudDocumentName;
#endif

@end

#pragma mark - MKFeedParser

@interface MKFeedParser () 

- (void)parserResults:(id)results;
- (void)archiveComplete:(id)results;

@property (nonatomic, copy) MKRequestComplete requestCompleteBlock;
@property (nonatomic, copy) MKArchiveSuccessful archiveSuccessBlock;

@end

//---------------------------------------------------------------
// Implemntaion
//---------------------------------------------------------------

@implementation MKFeedParser

@synthesize url=mUrl, delegate, requestCompleteBlock=mRequestCompleteBlock, numberOfItems, archivePath, archiveResults, 
archiveSuccessBlock;

#if MKKIT_AVAILABLE_TO_MKFEEDS
@synthesize cloudDocumentName;
#endif

@dynamic sourceType, contentType;

#pragma mark - Creation

//---------------------------------------------------------------
// Creation
//---------------------------------------------------------------

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

//---------------------------------------------------------------
// Memory Managment
//---------------------------------------------------------------

-(void)dealloc {
    self.delegate = nil;
    self.requestCompleteBlock = nil;
    self.archivePath = nil;

#if MKKIT_AVAILABLE_TO_MKFEEDS
    self.cloudDocumentName = nil;
    
    MK_M_LOG(@"Dealloc");
#endif
    
    [mUrl release];
    
	[super dealloc];
}

#pragma mark - request

//---------------------------------------------------------------
// Requests
//---------------------------------------------------------------

- (void)request {
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    
    NSString *num = [NSString stringWithFormat:@"&num=%i", self.numberOfItems];
    NSString *q = [NSString stringWithFormat:@"&q=%@", mUrl];
    NSString *requestURL = [NSString stringWithFormat:@"%@%@%@", MK_FEED_BASE_URL, num, q];
    
	urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];
    
	theConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	
#if MKKIT_AVAILABLE_TO_MKFEEDS 
    MK_E_LOG(@"Feed Request Made");
#endif
    
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

#pragma mark - Connection Delegate

//---------------------------------------------------------------
// Connection Delegate
//---------------------------------------------------------------

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
	
#if MKKIT_AVAILABLE_TO_MKFEEDS
    MK_E_LOG(@"Error %@", [error localizedDescription]);
#endif
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    ////////////////////////////////////////////////////////////
    // UNCOMMENT THESE LINES TO POST THE FEED DATA IN THE LOG //
    ////////////////////////////////////////////////////////////
    
	//NSString *data = [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding];
	//NSLog(@"%@", data);
    
#if MKKIT_AVAILABLE_TO_MKFEEDS 
    MK_E_LOG(@"Connection Finished");
#endif
    
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

//---------------------------------------------------------------
// Parse Results
//---------------------------------------------------------------

- (void)parserResults:(id)results {
#if MKKIT_AVAILABLE_TO_MKFEEDS
    MK_S_LOG(@"Parse Results Returned");
#endif
    
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
#if MKKIT_AVAILABLE_TO_MKFEEDS
            else {
                operation.cloudDocumentName = self.cloudDocumentName;
            }
#endif
            NSOperationQueue *operationQueue = [NSOperationQueue mainQueue];
            [operationQueue addOperation:operation];
            
            [operation release];
        }
    }
}

#pragma mark - Archiving

//---------------------------------------------------------------
// Archiving
//---------------------------------------------------------------

- (void)setArchiveResultsToPath:(NSString *)path successful:(void (^)(BOOL complete))successful {
    mArchiveType = MKFeedArchiveWithFile;
    
    self.archiveResults = YES;
    self.archivePath = path;
    self.archiveSuccessBlock = successful;
}

#if MKKIT_AVAILABLE_TO_MKFEEDS

- (void)setArchiveToCloudFileNamed:(NSString *)name successful:(void (^)(BOOL complete))successful {
    mArchiveType = MKFeedArchiveWithCloud;
    
    self.archiveResults = YES;
    self.cloudDocumentName = name;
    self.archiveSuccessBlock = successful;
}

#endif

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

//---------------------------------------------------------------
// Depreceated Methods
//---------------------------------------------------------------

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

//---------------------------------------------------------------
// Implementation
//---------------------------------------------------------------

@implementation MKFeedParseOperation

@synthesize archive, fromIndex, archivePath, archiveType;

#if MKKIT_AVAILABLE_TO_MKFEEDS
@synthesize cloudDocumentName;
#endif

#pragma mark - Creation

//---------------------------------------------------------------
// Creation
//---------------------------------------------------------------

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

//---------------------------------------------------------------
// Memory Managment
//---------------------------------------------------------------

- (void)dealloc {
    [items release];
    [JSONData release];
    [target release];
    
    mainThreadCallBack = nil;
    self.archivePath = nil;
    
#if MKKIT_AVAILABLE_TO_MKFEEDS
    self.cloudDocumentName = nil;
    
    MK_M_LOG(@"Dealloc");
#endif
    
    [super dealloc];
}

#pragma mark - Main

//---------------------------------------------------------------
// Main Method
//---------------------------------------------------------------

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
#if MKKIT_AVAILABLE_TO_MKFEEDS
        else if (self.archiveType == MKFeedArchiveWithCloud) {
            [archiver syncWithCloudFileNamed:self.cloudDocumentName completion: ^ (MKArchiverSyncResults syncResults) {
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
#endif

        [archiver release];
    }
}

#pragma mark - Parse

//---------------------------------------------------------------
// Parse Action
//---------------------------------------------------------------

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
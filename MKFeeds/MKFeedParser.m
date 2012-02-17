//
//  MKRSSFeed.m
//  MKKit
//
//  Created by Matthew King on 8/13/10.
//  Copyright 2010-2012 Matt King. All rights reserved.
//

#import "MKFeedParser.h"
#import "MKFeedItem.h"

#define MK_FEED_BASE_URL        @"https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&scoring=h"

#pragma mark - JSON Parse Operation

@interface MKJSONParseOperation : NSOperation {
@private
    NSData *JSONData;
    id target;
    SEL mainThreadCallBack;
}

- (id)initWithData:(NSData *)data target:(id)target mainThreadCallBack:(SEL)callBack;

@end

#pragma mark - MKFeedParser

@interface MKFeedParser () 

- (void)parserResults:(NSMutableArray *)results;

@end

@implementation MKFeedParser

@synthesize url=mUrl, delegate, requestCompleteBlock=mRequestCompleteBlock, numberOfItems;

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
    
	[super dealloc];
}

#pragma mark - request

- (void)request {
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    
    NSString *num = [NSString stringWithFormat:@"&num=%i", self.numberOfItems];
    NSString *q = [NSString stringWithFormat:@"&q=%@", mUrl];
    NSString *requestURL = [NSString stringWithFormat:@"%@%@%@", MK_FEED_BASE_URL, num, q];
    
	request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    
	theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if (theConnection) {
		requestData = [[NSMutableData data] retain];
	} 
    
	[mUrl release];
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
	
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
	[request release];
    
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
	
    MKJSONParseOperation *parseOpperation = [[MKJSONParseOperation alloc] initWithData:requestData target:self mainThreadCallBack:@selector(parserResults:)];
    [parseQueue addOperation:parseOpperation];
    [parseOpperation release];
    
	[theConnection release];
	[requestData release];
    
    //[[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
	[request release];
}

#pragma mark - Parse Results

- (void)parserResults:(NSMutableArray *)results {
    if (MKRSSFeedTags.usesCompletionBlock) {
        self.requestCompleteBlock(results, nil);
    }
    else {
        [delegate feed:self didReturnData:results];
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

@implementation MKJSONParseOperation

#pragma mark - Creation

- (id)initWithData:(NSData *)data target:(id)_target mainThreadCallBack:(SEL)callBack {
    self = [super init];
    if (self) {
        JSONData = [data retain];
        target = [_target retain];
        mainThreadCallBack = callBack;
        
        MKGoogleJSONTitle = @"title";
        MKGoogleJSONLink = @"link";
        MKGoogleJSONContentSnippet = @"contentSnippet";
        MKGoogleJSONAuthor = @"author";
    }
    return self;
}

#pragma mark - Memory

- (void)dealloc {
    [JSONData release];
    [target release];
    
    [super dealloc];
}

#pragma mark - Main

- (void)main {
    NSError *error;
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:JSONData options:kNilOptions error:&error];
    
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
    
    [target performSelectorOnMainThread:mainThreadCallBack withObject:rtnItems waitUntilDone:YES];
    
    [rtnItems release];
}

@end
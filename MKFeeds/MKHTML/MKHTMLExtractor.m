//
//  MKTextExtractor.m
//  MKKit
//
//  Created by Matthew King on 10/23/11.
//  Copyright (c) 2011-2012 Matt King. All rights reserved.
//

#import "MKHTMLExtractor.h"
#import "MKHTMLParser.h"
#import "MKHTMLNode.h"
#import "MKHTMLExtractorDelegate.h"

#import <MKKit/MKFeeds/NSString+MKFeedParser.h>
#import <UIKit/UIKit.h>

//---------------------------------------------------------------
// Type Deffs
//---------------------------------------------------------------

typedef void (^MKHTMLExtractorPageTextHandler)(NSString *pageText, NSError *error);

//---------------------------------------------------------------
// Functions
//---------------------------------------------------------------

MKHTMLExtractorStyleSheet MKHTMLExtractorStyleSheetMake(int fontSize, NSString *fontColor, NSString *backgroundColor) {
    MKHTMLExtractorStyleSheet sheet;
    
    sheet.fontSize = fontSize;
    sheet.fontColor = fontColor;
    sheet.backgroundColor = backgroundColor;
    
    return sheet;
}

//---------------------------------------------------------------
// Interfaces
//---------------------------------------------------------------

#pragma mark - Extraction Operation

@interface MKHTMLExtractionOperation : NSOperation {
@private
    NSData *data;
    id target;
    SEL mainThreadCallBack;
    
    NSArray *attributesArray;
}

- (id)initWithData:(NSData *)data target:(id)target mainThreadCallBack:(SEL)callBack;

- (NSString *)mainBodyHTMLFromParsedData:(MKHTMLParser *)parsedData;
- (void)extractFromData:(NSData *)data;
- (void)findNextPageFromParsedData:(MKHTMLParser *)parsedData;
- (void)postExtractionError;

- (NSString *)styledTitleFromNode:(MKHTMLNode *)node;
- (NSString *)styledParagraphFromNode:(MKHTMLNode *)node;
- (NSString *)styledEmbedFromNode:(MKHTMLNode *)node;
- (NSString *)styledBlockquoteNode:(MKHTMLNode *)node;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger attemptCount;

@property (nonatomic, assign) BOOL useCustomStyle;
@property (nonatomic, assign) BOOL requestComplete;
@property (nonatomic, assign) BOOL articalTitleSet;

@property (nonatomic, assign) MKHTMLExtractorRequestType requestType;

@property (nonatomic, copy) NSString *htmlHeaderString;
@property (nonatomic, copy) NSString *URL;

@end

#pragma mark - HTML Attribute

@interface MKHTMLAttributeValue : NSObject 

- (id)initWithAttribute:(NSString *)attrib value:(NSString *)val;

@property (nonatomic, copy) NSString *attribute;
@property (nonatomic, copy) NSString *value;

@end

#pragma mark - HTML Extractor

@interface MKHTMLExtractor ()

- (id)init;
- (void)request;
- (void)requestPage:(NSString *)url;
- (void)postExtractionError:(NSError *)error;
- (void)startExtractionOperation;
- (void)extractionResult:(id)result;

@property (nonatomic, copy) MKHTMLExtractorPageTextHandler pageTextHandler;

@end

//---------------------------------------------------------------
// Implementation
//---------------------------------------------------------------

@implementation MKHTMLExtractor

@synthesize articleTitle, articleAuthor, requestHandler, requestType, delegate, pageTextHandler;

@dynamic results, numberOfPages, optimizeOutputForiPhone, /*combinesPages,*/ styledOutput, styleSheet;

#pragma mark - Creation

//---------------------------------------------------------------
// Creation
//---------------------------------------------------------------

- (id)init {
    self = [super init];
    if (self) {
        MKHTMLExtractorFlags.articalTitleSet = NO;
        MKHTMLExtractorFlags.usesCustomStyle = NO;
        MKHTMLExtractorFlags.currentPage    = 1;
    }
    return self;
}

- (id)initWithURL:(NSString *)aURL {
	if (self = [super init]) {
        if (aURL == nil) {
            MKHTMLExtractorNILURLExecption = @"MKHTMLExtractorNILURLExectption";
            NSException *ecxeption = [NSException exceptionWithName:MKHTMLExtractorNILURLExecption reason:@"URL cannot be a nil value." userInfo:nil];
            @throw ecxeption;
        }
		URL = [aURL copy];
        
        MKHTMLExtractorFlags.requestFromURL = YES;
        
        self = [self init];
    }
	return self; 
}

- (id)initWithHTMLString:(NSString *)htmlString {
    self = [super init];
    if (self) {
        if (htmlString == nil) {
            MKHTMLExtractorNILHTMLStringException = @"MKHTMLExtractorNILHTMLStringExeption";
            NSException *exception = [NSException exceptionWithName:MKHTMLExtractorNILHTMLStringException reason:@"htmlString cannot be a nil value" userInfo:nil];
            @throw exception;
        }
        mHTMLString = [htmlString copy];
        MKHTMLExtractorFlags.requestFromURL = NO;
        
        self = [self init];
    }
    return self;
}

#pragma mark - Memory Mangament

//---------------------------------------------------------------
// Interfaces
//---------------------------------------------------------------

- (void)dealloc {
    self.articleTitle = nil;
    self.pageTextHandler = nil;
    self.delegate = nil;
    
    [aConnection release];
    [request release];
    [requestData release];
    [mHTMLHeaderString release];
    
    if (MKHTMLExtractorFlags.requestFromURL) {
        [URL release];
    }
    
#if MKKIT_AVAILABLE_TO_MKFEEDS
    MK_M_LOG(@"Dealloc");
#endif
    
    [super dealloc];
}

#pragma mark - Accessor Methods

//---------------------------------------------------------------
// Accessor Methods
//---------------------------------------------------------------

#pragma mark Getters

- (BOOL)styledOutput {
    return MKHTMLExtractorFlags.usesCustomStyle;
}

- (BOOL)combinesPages {
    return MKHTMLExtractorFlags.combinesPages;
}

- (MKHTMLExtractorStyleSheet)styleSheet {
    return mStyleSheet;
}

#pragma mark Setters

- (void)setStyleSheet:(MKHTMLExtractorStyleSheet)_styleSheet {
    mStyleSheet = _styleSheet;
    MKHTMLExtractorFlags.useStyleSheet = YES;
    self.styledOutput = YES;
}

- (void)setStyledOutput:(BOOL)_styledOutput {
    MKHTMLExtractorFlags.usesCustomStyle = _styledOutput;
    if (_styledOutput) {
        if ([self.delegate respondsToSelector:@selector(extractorHTMLHeaderPath:)]) {
            mHTMLHeaderString = [[NSString alloc] initWithContentsOfFile:[self.delegate extractorHTMLHeaderPath:self] encoding:NSUTF8StringEncoding error:nil];
        }
        else {
            NSString *fontSize = @"12";
            NSString *titleFontSize = @"16";
            NSString *fontColor = @"#000000";
            NSString *authorFontsize = @"10";
            NSString *backgroundColor = @"#ffffff";
            
            if (MKHTMLExtractorFlags.useStyleSheet) {
                fontSize = [NSString stringWithFormat:@"%i", mStyleSheet.fontSize];
                titleFontSize = [NSString stringWithFormat:@"%i", (mStyleSheet.fontSize + 4)];
                authorFontsize = [NSString stringWithFormat:@"%i", (mStyleSheet.fontSize - 2)];
                fontColor = mStyleSheet.fontColor;
                backgroundColor = mStyleSheet.backgroundColor;
            }
            mHTMLHeaderString = [NSString stringWithFormat:@"<html><head><meta name=\"viewport\" content=\"initial-scale = 1.0, user-scalable = no\"/><style type=\"text/css\">"]; 
            mHTMLHeaderString = [mHTMLHeaderString stringByAppendingFormat:@".title { font-size: %@pt; font-weight: bold; color: %@;}", titleFontSize, fontColor]; 
            mHTMLHeaderString = [mHTMLHeaderString stringByAppendingFormat:@".article { font-size: %@pt; color: %@;}", fontSize, fontColor];
            mHTMLHeaderString = [mHTMLHeaderString stringByAppendingFormat:@".author { font-size: %@pt; color: %@; font-style: italic;}", authorFontsize, fontColor];
            mHTMLHeaderString = [mHTMLHeaderString stringByAppendingFormat:@".source { font-size: %@pt; color: %@; font-style: italic; word-wrap:break-word;}", authorFontsize, fontColor];
            mHTMLHeaderString = [mHTMLHeaderString stringByAppendingFormat:@"</style></head><body bgColor=\"%@\">", backgroundColor];
            
            [mHTMLHeaderString retain];
        }
    }
}

- (void)setArticleTitle:(NSString *)title {
    MKHTMLExtractorFlags.articalTitleSet = YES;
    
    mHTMLHeaderString = [[mHTMLHeaderString stringByAppendingFormat:@"<div class=\"title\">%@</div>", title] retain];
}

- (void)setArticleAuthor:(NSString *)_articleAuthor {
    MKHTMLExtractorFlags.articalAuthorSet = YES;
    
    mHTMLHeaderString = [[mHTMLHeaderString stringByAppendingFormat:@"<br><div class=\"author\">%@</div>", _articleAuthor] retain];
}

- (void)setCombinesPages:(BOOL)_combinesPages {
    MKHTMLExtractorFlags.combinesPages = _combinesPages;
}

#pragma mark - Request Methods

//---------------------------------------------------------------
// Reqest
//---------------------------------------------------------------

- (void)request {
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    
	request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
	aConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
    requestData = [[NSMutableData data] retain];
    
#if MKKIT_AVAILABLE_TO_MKFEEDS
    MK_S_LOG(@"Request Made");
#endif
}

- (void)requestType:(MKHTMLExtractorRequestType)type handler:(void (^)(NSString *pageText, NSError *error))handler; {
    self.pageTextHandler = handler;
    self.requestType = type;
    
    switch (type) {
        case MKHTMLExtractorMainBodyHTMLRequest: {
            [self request]; 
        } break;
        case MKHTMLExtractorFirstParagraph: {
            requestData = [(NSMutableData *)[mHTMLString dataUsingEncoding:[NSString defaultCStringEncoding]] retain];
            [self startExtractionOperation];
            [mHTMLString release];
        } break;
        default:
            break;
    }
}

- (void)requestPagesWithHandler:(void (^)(NSString *pageText, NSError *error))handler; {
    self.pageTextHandler = handler;
    self.requestType = MKHTMLExtractorMainBodyHTMLRequest;
    
    [self request];
}

- (void)requestPage:(NSString *)url {
    URL = [url copy];
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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)_error {
    [self postExtractionError:nil];
    
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    [request release];
    [aConnection release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    ////////////////////////////////////////////////////////////
    // UNCOMMENT THESE LINES TO POST THE FEED DATA IN THE LOG //
    ////////////////////////////////////////////////////////////
    
	//NSString *data = [[NSString alloc] initWithData:requestData encoding:NSASCIIStringEncoding];
	//NSLog(@"%@", data);
    
    [self startExtractionOperation];
    
#if MKKIT_AVAILABLE_TO_MKFEEDS
    MK_S_LOG(@"Begining Extraction");
#endif
    
}

#pragma mark - Extration Operations

//---------------------------------------------------------------
// Extraction Operations
//---------------------------------------------------------------

- (void)startExtractionOperation {
    MKHTMLExtractionOperation *operation = [[MKHTMLExtractionOperation alloc] initWithData:requestData target:self mainThreadCallBack:@selector(extractionResult:)];
    operation.currentPage = MKHTMLExtractorFlags.currentPage;
    operation.useCustomStyle = MKHTMLExtractorFlags.usesCustomStyle;
    operation.articalTitleSet = MKHTMLExtractorFlags.articalTitleSet;
    operation.htmlHeaderString = mHTMLHeaderString;
    operation.URL = URL;
    operation.requestType = self.requestType;
    
    NSOperationQueue *operationQueue = [NSOperationQueue currentQueue];
    [operationQueue addOperation:operation];
    [operation release];

}

- (void)extractionResult:(id)result {
    if ([result isKindOfClass:[NSString class]] ) {
        if (self.pageTextHandler) {
            self.pageTextHandler((NSString *)result, nil);
        }
        if ([self.delegate respondsToSelector:@selector(extractor:didFindPage:content:)]) {
            [self.delegate extractor:self didFindPage:MKHTMLExtractorFlags.currentPage content:(NSString *)result];
        }
        
#if MKKIT_AVAILABLE_TO_MKFEEDS
        MK_S_LOG(@"Found Article body");
#endif

    }
    else if ([result isKindOfClass:[NSURL class]] ) {
        MKHTMLExtractorFlags.currentPage = (MKHTMLExtractorFlags.currentPage + 1);
        
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        
        request = [[NSMutableURLRequest alloc] initWithURL:(NSURL *)result cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
        aConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        requestData = [[NSMutableData data] retain];
        
#if MKKIT_AVAILABLE_TO_MKFEEDS
        MK_S_LOG(@"Found next page");
#endif

    }
    else if ([result isKindOfClass:[NSError class]]) {
        [self postExtractionError:(NSError *)result];
        
#if MKKIT_AVAILABLE_TO_MKFEEDS
        MK_S_LOG(@"Error: %@", [(NSError *)result localizedDescription]);
#endif

    }
}

#pragma mark Errors

- (void)postExtractionError:(NSError *)error {
    if (!error) {
        MKHTMLExtractorNoResultsFoundError = @"MKHTMLExtratorNoResultsFoundError";
        MKHTMLExtractorErrorUserInfoURLKey = @"MKHTMLExtractorErrorUserInfoURLKey";
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:URL forKey:MKHTMLExtractorErrorUserInfoURLKey];
        error = [NSError errorWithDomain:MKHTMLExtractorNoResultsFoundError code:2001 userInfo:userInfo];
    }
    
    if (self.pageTextHandler) {
        self.pageTextHandler(nil, error);
    }
    if ([delegate respondsToSelector:@selector(extractor:didError:)]) {
        [self.delegate extractor:self didError:error];
    }
}

#pragma mark - Deprecations

//---------------------------------------------------------------
// Depreceations
//---------------------------------------------------------------

- (NSDictionary *)results {
    return nil;
}

- (NSInteger)numberOfPages {
    return 0;
}

- (void)requestType:(MKHTMLExtractorRequestType)type withHandler:(MKHTMLExtractorRequestHandler)handler {
    
}

- (void)setOptimizeOutputForiPhone:(BOOL)optomize {
}

- (BOOL)optimizeOutputForiPhone {
    return NO;
}

@end

#pragma mark - Extraction Opertation

//---------------------------------------------------------------
// Implementation
//---------------------------------------------------------------

@implementation MKHTMLExtractionOperation

@synthesize currentPage, requestType, useCustomStyle, attemptCount, requestComplete,
htmlHeaderString, articalTitleSet, URL;

#pragma mark - Creation

//---------------------------------------------------------------
// Creation
//---------------------------------------------------------------

- (id)initWithData:(NSData *)_data target:(id)_target mainThreadCallBack:(SEL)callBack {
    self = [super init];
    if (self) {
        data = [_data retain];
        target = [_target retain];
        mainThreadCallBack = callBack;
        
        MKHTMLAttributeValue *first = [[[MKHTMLAttributeValue alloc] initWithAttribute:@"id" value:@"text"] autorelease];
        MKHTMLAttributeValue *second = [[[MKHTMLAttributeValue alloc] initWithAttribute:@"class" value:@"article"] autorelease];
        MKHTMLAttributeValue *third = [[[MKHTMLAttributeValue alloc] initWithAttribute:@"id" value:@"post"] autorelease];
        MKHTMLAttributeValue *fourth = [[[MKHTMLAttributeValue alloc] initWithAttribute:@"class" value:@"entry"] autorelease];
        MKHTMLAttributeValue *fifth = [[[MKHTMLAttributeValue alloc] initWithAttribute:@"id" value:@"content"] autorelease];
        MKHTMLAttributeValue *sixth = [[[MKHTMLAttributeValue alloc] initWithAttribute:@"class" value:@"MboxContent"] autorelease];
                
        attributesArray = [[NSArray alloc] initWithObjects:first, second, third, fourth, fifth, sixth, nil];
        
        self.attemptCount = 0;
    }
    return self;
}

#pragma mark - Memory

//---------------------------------------------------------------
// Memory
//---------------------------------------------------------------

- (void)dealloc {
    self.htmlHeaderString = nil;
    self.URL = nil;
    
    [data release];
    [target release];
    [attributesArray release];
    
#if MKKIT_AVAILABLE_TO_MKFEEDS
    MK_M_LOG(@"Dealloc");
#endif
    
    [super dealloc];
}
#pragma mark - Main

//---------------------------------------------------------------
// Main Method
//---------------------------------------------------------------

- (void)main {
    [self extractFromData:data];
}

#pragma mark - Extractor Methods

//---------------------------------------------------------------
// Etraction Methods
//---------------------------------------------------------------

- (void)extractFromData:(NSData *)_data {
    MKHTMLParser *parsedData = nil;
    
    @try {
        parsedData = [[MKHTMLParser alloc] initWithData:_data];
    }
    @catch (NSException *exception) {
        [self postExtractionError];
    }
    @finally {}
    
    self.requestComplete = YES;
    
    switch (self.requestType) {
        case MKHTMLExtractorMainBodyHTMLRequest: {
            for (MKHTMLAttributeValue *attribute in attributesArray) {
                NSString *text = [self mainBodyHTMLFromParsedData:parsedData];
                if ([text length] > 1) {
                    if (self.useCustomStyle && self.currentPage == 1) {
                        text = [self.htmlHeaderString stringByAppendingString:text];
                    }
                    
                    [target performSelectorOnMainThread:mainThreadCallBack withObject:text waitUntilDone:YES];
                    
                    self.attemptCount = 0;
                    
                    [self findNextPageFromParsedData:parsedData];
                    break;
                }
                else {
                    self.attemptCount = (self.attemptCount + 1);
                    
                    if (self.attemptCount == [attributesArray count]) {
                        [self postExtractionError];
                    }
                }
            }
        } break;
        case MKHTMLExtractorFirstParagraph: {
            MKHTMLNode *firstp = [[parsedData root] childNodeNamed:@"p"];
            NSString *firstpText = [firstp allText];
            NSString *text = [firstpText stringByRemovingNewLinesAndWhitespace];
            
            if (text) {
                [target performSelectorOnMainThread:mainThreadCallBack withObject:text waitUntilDone:YES];
            }
            else {
                [self postExtractionError];
            }
        } break;
        default:
            break;
    }
    
    [parsedData release];
}

#pragma mark Main Body Text

- (NSString *)mainBodyHTMLFromParsedData:(MKHTMLParser *)parsedData; {
    NSMutableString *article = nil;
    
    if (self.requestComplete) {
        MKHTMLAttributeValue *attribute = nil;
        BOOL attemptsLeft = YES;
        @try {
            attribute = (MKHTMLAttributeValue *)[attributesArray objectAtIndex:self.attemptCount];
        }
        @catch (NSException *exception) {
            [self postExtractionError];
        }
        @finally {
        }
        
        NSArray *elements = [[parsedData body] childrenNamed:@"article"];
        
        if (attemptsLeft) {
            if ([elements count] == 0) {
                elements = [[parsedData body] childrenWithAttribute:attribute.attribute  value:attribute.value allowPartial:YES];
            }
            article = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
            
            for (MKHTMLNode *node in elements) {
                NSArray *children = [node children];
                for (MKHTMLNode *child in children) {
                    switch ([child nodeType]) {
                        case MKHTMLNodeH1: {
                            if (self.articalTitleSet == NO) {
                                if (self.currentPage == 1) {
                                    if (self.useCustomStyle) {
                                        [article appendString:[self styledTitleFromNode:child]];
                                    }
                                    else {
                                        [article appendString:[child htmlString]]; 
                                    }
                                }
                            }
                        } break;
                        case MKHTMLNodeP: {
                            if (self.useCustomStyle) {
                                [article appendString:[self styledParagraphFromNode:child]];
                            }
                            else {
                                [article appendString:[child htmlString]];
                            }
                        } break;
                            
                        case MKHTMLNodeBlockquote: {
                            if (self.useCustomStyle) {
                                [article appendString:[self styledBlockquoteNode:child]];
                            }
                            else {
                                [article appendString:[child htmlString]];
                            }
                        } break;
                        default: break;
                    }
                }
            }
        }
    }
    return article;
}

#pragma mark Main Body Helpers

//---------------------------------------------------------------
// Extraction Helpers
//---------------------------------------------------------------


- (NSString *)styledTitleFromNode:(MKHTMLNode *)node {
    NSMutableString *rtn = [NSMutableString string];
    
    [rtn appendString:@"<div class=\"title\">"];
    [rtn appendString:[node allText]];
    [rtn appendString:@"</div>"];
    
    return rtn;
}

- (NSString *)styledParagraphFromNode:(MKHTMLNode *)node {
    NSMutableString *rtn = [NSMutableString string];
    
    if ([node childNodeNamed:@"iframe"]) {
        [rtn appendString:[self styledEmbedFromNode:[node childNodeNamed:@"iframe"]]];
    }
    
    else if ([node childNodeNamed:@"img"]) {
        [rtn appendString:[self styledEmbedFromNode:[node childNodeNamed:@"img"]]];
    }
    else {
        [rtn appendString:@"<div class=\"article\">"];
        [rtn appendString:[node htmlString]];
        [rtn appendString:@"</div>"];
    }
    
    return rtn;
}

- (NSString *)styledEmbedFromNode:(MKHTMLNode *)node {
    NSMutableString *rtn = [NSMutableString string];
    
    if (MK_DEVICE_IS_IPHONE) {
        NSString *src = [node valueOfAttribute:@"src"];
        
        NSString *baseURL = [[NSURL URLWithString:src] host];
        
        if (!baseURL) {
            NSString *host = [[NSURL URLWithString:URL] host];
            NSString *scheme = [[NSURL URLWithString:URL] scheme];
            src = [NSString stringWithFormat:@"%@://%@%@", scheme, host, src];
            src = [src stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        switch ([node nodeType]) {
            case MKHTMLNodeIFrame:  [rtn appendFormat:@"<iframe allowfullscreen=\"\" frameborder=\"0\" heigh=\"\" width=\"300\" src=\"%@\"></iframe>", src]; break;
            case MKHTMLNodeImg:     [rtn appendFormat:@"<img src=\"%@\" width=\"300\" />", src]; break;
            default:                [rtn appendString:[node htmlString]]; break;
        }
    }
    else {
        [rtn appendString:[node htmlString]];
    }
    
    return rtn;
}

- (NSString *)styledBlockquoteNode:(MKHTMLNode *)node {
    NSMutableString *rtn = [NSMutableString string];
    
    [rtn appendString:@"<div class=\"article\">"];
    [rtn appendString:[node htmlString]];
    [rtn appendString:@"</div>"];
    
    return rtn;
}

#pragma mark Linked Pages

//---------------------------------------------------------------
// Linked Pages
//---------------------------------------------------------------

- (void)findNextPageFromParsedData:(MKHTMLParser *)parsedData {
    NSString *nextPageNumber = [NSString stringWithFormat:@"%i", (self.currentPage + 1)];
    NSArray *links = [[parsedData body] childrenNamed:@"a"];
    
    BOOL linkFound = NO;
    
    for (MKHTMLNode *node in links) {
        if ([[node allText] isEqualToString:nextPageNumber]) {
            self.currentPage = [nextPageNumber intValue];
            linkFound = YES;
            
            NSString *url = [node valueOfAttribute:@"href"];
            
            if (![url hasPrefix:@"#"]) {
                NSString *baseURL = [[NSURL URLWithString:url] host];
                if (!baseURL) {
                    NSString *host = [[NSURL URLWithString:URL] host];
                    NSString *scheme = [[NSURL URLWithString:URL] scheme];
                    url = [NSString stringWithFormat:@"%@://%@%@", scheme, host, url];
                }
                NSURL *nextPageURL = [NSURL URLWithString:url];
                [target performSelectorOnMainThread:mainThreadCallBack withObject:nextPageURL waitUntilDone:YES];
                return;
            }
        }
    }
    
    if (!linkFound) {
        NSString *text = [NSString string];
        text = [text stringByAppendingString:@"<p><div class=\"source\">"];
        text = [text stringByAppendingFormat:@"Source: %@</div>", self.URL];
        text = [text stringByAppendingString:@"</body></html>"];
        
        [target performSelectorOnMainThread:mainThreadCallBack withObject:text waitUntilDone:YES];
        return;
    }
}

#pragma mark Errors

//---------------------------------------------------------------
// Errors
//---------------------------------------------------------------

- (void)postExtractionError {
    MKHTMLExtractorNoResultsFoundError = @"MKHTMLExtratorNoResultsFoundError";
    MKHTMLExtractorErrorUserInfoURLKey = @"MKHTMLExtractorErrorUserInfoURLKey";
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:URL forKey:MKHTMLExtractorErrorUserInfoURLKey];
    NSError *error = [NSError errorWithDomain:MKHTMLExtractorNoResultsFoundError code:2001 userInfo:userInfo];
    
    [target performSelectorOnMainThread:mainThreadCallBack withObject:error waitUntilDone:YES];
}

@end

#pragma mark - Attribute Value

//---------------------------------------------------------------
// Implementation
//---------------------------------------------------------------

@implementation MKHTMLAttributeValue

@synthesize attribute, value;

#pragma mark - Creation

//---------------------------------------------------------------
// Creation
//---------------------------------------------------------------

- (id)initWithAttribute:(NSString *)attrib value:(NSString *)val {
    self = [super init];
    if (self) {
        self.attribute = attrib;
        self.value = val;
    }
    return self;
}

#pragma mark - Memory

//---------------------------------------------------------------
// Memory
//---------------------------------------------------------------

- (void)dealloc {
    self.attribute = nil;
    self.value = nil;
    
    [super dealloc];
}

@end

//
//  MKTextExtractor.h
//  MKKit
//
//  Created by Matthew King on 10/23/11.
//  Copyright (c) 2011-2012 Matt King. All rights reserved.
//

#import <MKKit/MKFeeds/MKFeedsAvailability.h>
#import <MKKit/MKFeeds/MKFeedsErrorControl.h>

typedef void (^MKHTMLExtractorRequestHandler)(NSDictionary *results, NSError *error);

typedef enum {
    MKHTMLExtractorRequestNone,
    MKHTMLExtractorMainBodyHTMLRequest,
    MKHTMLExtractorFirstParagraph,
} MKHTMLExtractorRequestType;

typedef struct {
    int fontSize;
    NSString *fontColor;
    NSString *backgroundColor;
} MKHTMLExtractorStyleSheet;

MKHTMLExtractorStyleSheet MKHTMLExtractorStyleSheetMake(int fontSize, NSString *fontColor, NSString *backgroundColor);

@class MKHTMLParser;

@protocol MKHTMLExtractorDelegate;

/**-----------------------------------------------------------------------------------
 *Overview*
 
 MKHTMLExtractor looks at given web pages and pulls out specific data. For example the 
 article from a web page containing a news story. MKHTMLExtractor has preset types of
 extraction types that can be used.
 
 * `MKHTMLExtactorMainBodyTextRequest` : Finds the main text of a web page and extacts it 
 as a NSString that is in an HTML format.
 * `MKHTMLExtractorFirstParagraph` : Finds the first paragraph of the a web pages main body
 text and returns it as a NSString in an HTML format.
 
 *Request Handlers*
 
 MKHTMLExtractor supports the use of code blocks to handle responces from an extraction
 request. Call the requestType:handler: method to make use of the handler block.
 The handle block will pass an NSString object with the extraction results. 
 
 *Addtional Information*
 
 Supports the default Debug/Event loggin of MKKit, if MKKit is available. You can toggle what
 type of logging you want to use from the `MKAvailability.h` file.
------------------------------------------------------------------------------------*/

@interface MKHTMLExtractor : NSObject {
@private
    NSMutableURLRequest *request;
    NSURLConnection *aConnection;
    NSMutableData *requestData;
    NSString *mHTMLHeaderString;
    NSString *mHTMLString;
    NSString *URL;
    
    MKHTMLExtractorStyleSheet mStyleSheet;
    
    struct {
        BOOL requestComplete;
        BOOL requestFromURL;
        BOOL usesCustomStyle;
        BOOL articalTitleSet;
        BOOL articalAuthorSet;
        BOOL combinesPages;
        BOOL useStyleSheet;
        int currentPage;
    } MKHTMLExtractorFlags;
}

///--------------------------------------------
/// @name Creating Instance
///--------------------------------------------

/**
 Creates an instance of MKHTMLExtractor
 
 @param aURL the address of the website that data
 will be extracted from. Cannot be nil.
 
 @exception MKHTMLExtractorNILURLException : exeption is raised if the aURL 
 parameter is nil. Execption is catchable.
 
 @return MKHTMLExtractor instance
*/
- (id)initWithURL:(NSString *)aURL;

/**
 Creates an instance of MKHTMLExtractor
 
 @param htmlString an NSString representation of an HTML file
 
 @exception MKHTMLExtractorNILHTMLException : exception is raised if the the 
 htmlString is nil
 
 @return MKHTMLExtractor instance
*/
- (id)initWithHTMLString:(NSString *)htmlString;

///--------------------------------------------
/// @name Customize Output
///--------------------------------------------

/**
 Set a NSString to this property for the title of an article. If the property
 is set the extractor will not look for the title of an article, but use the 
 this property instead.
 
 @warning *Note* Setting this property does nothing if the requestType is not
 `MKHTMLExtractorMainBodyHTMLRequest`.
*/
@property (nonatomic, copy) NSString *articleTitle;

/** Set this string to list the articles author below the title. */
@property (nonatomic, copy) NSString *articleAuthor;

///--------------------------------------------
/// @name Styling Output
///--------------------------------------------

/**
 Set this property to `YES` to optimize the HTML output for display on 
 the iPhone. HTML code will be inserted into the output to assist with
 display.
 
 When set to `YES` the delegate method extactorHTMLHeaderPath: method is called.
 If this method is not used or returns `nil`, generic HTML code will be added.
 
 @see MKHTMLExtractorDelegate for more information.
*/
@property (nonatomic, assign) BOOL styledOutput;

/**
 Provide a `MKHTMLExtractorStyleSheet` and the extractor will generate css code
 and add it the generated output. 
 
 You can create a`MKHTMLExtractorStyleSheet` by using the 
 `MKHTMLExtractorStyleSheet MKHTMLExtractorStyleSheetMake(int fontSize, NSString *fontColor, NSString *backgroundColor)`
 function. 
 
 The font color and backgroundColor parameters need to be a string representation of 
 the hexidecimal color code.  For example white would be `#ffffff` or black would be `#000000`.
 
 @warning *Note* Setting this property will automaically set the styledOutput property to `YES`.
 the extractorHTMLHeaderPath: delegate method returns the path to an HTML header, the styles provided
 here will be overiden.
*/
@property (nonatomic, assign) MKHTMLExtractorStyleSheet styleSheet;

///--------------------------------------------
/// @name Preforming Requests
///--------------------------------------------

#if NS_BLOCKS_AVAILABLE

/**
 Makes a request from the supplied URL, preforms an extraction, and
 passes the results through the handler block.
 
 @param type The type of extraction to preform. Optional types are:
 
 * MKHTMLExtractorMainBodyText : Extracts the main text of the web site.
 This most suttable for getting a news article out of a page.
 * `MKHTMLExtractorFirstParagraph` : Finds the first paragraph of the a web pages main body
 text and returns it as a NSString in an HTML format.
 
 @param handler The code block to preform when the request is complete.
 The block will pass to parameters of and NSString, and NSError. The block
 is called each time a page is found.
*/
- (void)requestType:(MKHTMLExtractorRequestType)type handler:(void (^)(NSString *pageText, NSError *error))handler;

/**
 Makes a request from the supplied URL, performs and extraction, and pass
 the results through the handler block.
 
 This method sets the requestType to MKHTMLExtractorMainBodyRequest, and automatically
 looks for follow on pages. The handler block is called each time a page is 
 found.
*/
- (void)requestPagesWithHandler:(void (^)(NSString *pageText, NSError *error))handler;

#endif

/** The request that is currently being used. */
@property (nonatomic, assign) MKHTMLExtractorRequestType requestType;

///--------------------------------------------
/// @name Delegate
///--------------------------------------------

/**
 The MKHTMLExtractorDelegate
*/
@property (assign) id<MKHTMLExtractorDelegate> delegate;

///-------------------------------------------
/// @name Deprecations
///-------------------------------------------

/** DEPRECATED v1.0 */
- (void)requestType:(MKHTMLExtractorRequestType)type withHandler:(MKHTMLExtractorRequestHandler)handler MK_DEPRECATED_1_0;

/** DEPRECATED v1.0 */
@property (nonatomic, copy) MKHTMLExtractorRequestHandler requestHandler MK_DEPRECATED_1_0;

/** DEPRECATED v1.0 */
@property (nonatomic, assign) BOOL optimizeOutputForiPhone; //MK_DEPRECATED_1_0;

/** DEPRECATED v1.0 */
@property (nonatomic, readonly) NSDictionary *results;// MK_DEPRECATED_1_0;

/** DEPRECATED v1.0 */
@property (nonatomic, readonly) NSInteger numberOfPages;// MK_DEPRECATED_1_0;


@end
//
//  MKFeedsErrorControl.h
//  MKKit
//
//  Created by Matthew King on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MKFeedsAvailability.h"

/////////////////////// ERROR CODES //////////////////////////////////
static const int kMKHMLExtractorNoResultsCode              = 3001;
static const int kMKFeedItemArchiveErrorCode               = 3002;

NSString *MKHTMLExtractorNoResultsFoundError MK_VISIBLE_ATTRIBUTE;
NSString *MKHTMLExtractorErrorUserInfoURLKey MK_VISIBLE_ATTRIBUTE;

NSString *MKFeedItemArchiveError MK_VISIBLE_ATTRIBUTE;

////////////////////// EXCEPTIONS ////////////////////////////////////

/// Feed Parser
NSString *MKFeedParserNILURLException MK_VISIBLE_ATTRIBUTE;

/// HTML Extractor
NSString *MKHTMLExtractorNILURLExecption MK_VISIBLE_ATTRIBUTE;
NSString *MKHTMLExtractorNILHTMLStringException MK_VISIBLE_ATTRIBUTE;

/// HTML Parser
NSString *MKHTMLParserNILDataException MK_VISIBLE_ATTRIBUTE;
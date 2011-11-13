//
//  MKHTMLParser.m
//  MKKit
//
//  Created by Matthew King on 10/24/11.
//  Copyright (c) 2011 Matt King. All rights reserved.
//

#import "MKHTMLParser.h"

#import "MKHTMLNode.h"

@implementation MKHTMLParser

#pragma mark - Initalizer

-(id)initWithData:(NSData *)data {
	self = [super init];
    if (self) {
		htmlDoc = NULL;
        
		if (data) {
			CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
			CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
			const char *enc = CFStringGetCStringPtr(cfencstr, 0);
            
			htmlDoc = htmlReadDoc((xmlChar*)[data bytes], "", enc, XML_PARSE_NOERROR | XML_PARSE_NOWARNING);
		}
		else {
            MKHTMLParserNILDataException = @"MKHTMLParserNILDataException";
            NSException *exception = [NSException exceptionWithName:MKHTMLParserNILDataException reason:@"data parameter cannot be nil" userInfo:nil];
            @throw exception;
		}
	}
	return self;
}

#pragma mark - Memory Managment

- (void)dealloc {
    if (htmlDoc) {
        xmlFreeDoc(htmlDoc);
    }
    
    [super dealloc];
}


#pragma mark - Base Nodes

- (MKHTMLNode *)root {
    if (htmlDoc == NULL)
		return NULL;
    
	return [[[MKHTMLNode alloc] initWithNode:(xmlNode*)htmlDoc] autorelease];
}

- (MKHTMLNode *)body {
    if (htmlDoc == NULL) {
        return NULL;
    }
    
    return [[self root] childNodeNamed:@"body"]; 
}
 
@end
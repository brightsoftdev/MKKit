//
//  MKDocument.m
//  MKKit
//
//  Created by Matthew King on 3/28/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKDocument.h"
#import "MKAvailability.h"
#import "MKCloud.h"

//---------------------------------------------------------------
// Implementation
//---------------------------------------------------------------

@implementation MKDocument

@synthesize content; 

@dynamic cloudDocument;

//---------------------------------------------------------------
// Accessors
//---------------------------------------------------------------

- (BOOL)cloudDocument {
    BOOL ubiq = [[NSFileManager defaultManager] isUbiquitousItemAtURL:self.fileURL];
    return ubiq;
}

 
//---------------------------------------------------------------
// Memory
//---------------------------------------------------------------

- (void)dealloc {
    MK_M_LOG(@"Released document named: %@", self.localizedName);
    
    self.content = nil;
    
    [super dealloc];
}

//---------------------------------------------------------------
// Load Files
//---------------------------------------------------------------

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError {
    if (contents) {
        self.content = (NSData *)contents;
        return YES;
    }
    return NO;
}

//---------------------------------------------------------------
// Save Files
//---------------------------------------------------------------

- (id)contentsForType:(NSString *)typeName error:(NSError **)outError {
    return self.content;
}

@end

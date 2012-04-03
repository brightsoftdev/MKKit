//
//  NSURL+MKKit.m
//  MKKit
//
//  Created by Matthew King on 3/30/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "NSURL+MKKit.h"
#import "NSString+MKKit.h"

@implementation NSURL (MKKit)

//---------------------------------------------------------------
// Local Directories
//---------------------------------------------------------------

+ (NSURL *)documentsDirectoryURL {
    NSString *path = [NSString stringWithDocumentsDirectoryPath];
    NSURL *urlPath = [NSURL fileURLWithPath:path];
    
    return urlPath;
}

//---------------------------------------------------------------
// Cloud Directories
//---------------------------------------------------------------

+ (NSURL *)ubiquitousDocumentsDirectoryURL {
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSURL *ubiquitousPackage = [ubiq URLByAppendingPathComponent:@"Documents"];
    
    return ubiquitousPackage;
}

@end

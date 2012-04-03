//
//  MKCloud.m
//  MKKit
//
//  Created by Matthew King on 2/25/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKCloud.h"
#import "MKDocument.h"
#import "MKOperation.h"
#import "MKAvailability.h"

#import "NSString+MKKit.h"
#import "NSURL+MKKit.h"

//---------------------------------------------------------------
// Type Defs
//---------------------------------------------------------------

typedef void (^MKCloudLoadedFileHandler)(NSURL *fielURL);
typedef void (^MKCloudCreateDocumentHandler)(BOOL successful);
typedef void (^MKCloudPushDocumentHandler)(BOOL successful);
typedef void (^MKCloudRemoveDocumentHandler)(BOOL successful);
typedef void (^MKCloudOpenDocumentHandler)(id content);

//---------------------------------------------------------------
// Interfaces
//---------------------------------------------------------------

@interface MKCloud ()

- (void)queryDidFinish:(NSNotification *)notification;
- (void)movedToBackground:(NSNotification *)notification;

- (void)documentCreated:(MKDocument *)document success:(BOOL)success;
- (void)documentAddedToCloud:(MKDocument *)document success:(BOOL)success;
- (void)documentRemoved:(MKDocument *)document success:(BOOL)success;
- (void)openDocument:(MKDocument *)document;

@property (nonatomic, copy) MKCloudLoadedFileHandler loadFileHandler;
@property (nonatomic, copy) MKCloudCreateDocumentHandler createFileHandler;
@property (nonatomic, copy) MKCloudRemoveDocumentHandler removeFileHandler;
@property (nonatomic, copy) MKCloudPushDocumentHandler pushFileHandler;
@property (nonatomic, copy) MKCloudOpenDocumentHandler openFileHandler;

@end

//---------------------------------------------------------------
// Implementation
//---------------------------------------------------------------

@implementation MKCloud

@synthesize loadFileHandler, createFileHandler, removeFileHandler, pushFileHandler, openFileHandler, documents;

static MKCloud *sharedCloud;

#pragma mark - Creating 

//---------------------------------------------------------------
// Creation
//---------------------------------------------------------------

+ (id)cloudManager {
    @synchronized(self) {
        if (sharedCloud == nil) {
            sharedCloud = [[[self class] alloc] init];
        }
    }

    return sharedCloud;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedCloud == nil) {
            sharedCloud = [super allocWithZone:zone];
            return sharedCloud;
        }
    }
    return nil;
}

- (id)init {
    self = [super init];
    if (self) {
        backgroundqueue = dispatch_queue_create("com.mkkit.document access thread", NULL);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movedToBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

//---------------------------------------------------------------
// Memory
//---------------------------------------------------------------

- (void)dealloc {
    self.loadFileHandler = nil;
    self.createFileHandler = nil;
    self.removeFileHandler = nil;
    self.pushFileHandler = nil;
    
    [self.documents removeAllObjects]; self.documents = nil;
    
    dispatch_release(backgroundqueue);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];

    MK_M_LOG(@"Released Sigleton");
    
    [super dealloc];
}

#pragma mark - Availability

//---------------------------------------------------------------
// Finding Availability
//---------------------------------------------------------------

+ (BOOL)iCloudIsAvailable {
    BOOL availible = NO;
    
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    if (ubiq) {
        availible = YES;
    } 
    
    return availible;
}

#pragma mark - File Operations

//---------------------------------------------------------------
// File Operations
//---------------------------------------------------------------

- (void)createDocumentNamed:(NSString *)name content:(NSData *)content successful:(void(^)(BOOL))successful {
    self.createFileHandler = successful;
    
    NSURL *directoryURL = [NSURL documentsDirectoryURL];
    NSURL *fileURL = [directoryURL URLByAppendingPathComponent:name];
        
    dispatch_async(backgroundqueue,  ^ (void) {
        MKDocument *document = [[MKDocument alloc] initWithFileURL:fileURL];
        document.content = content;

        [document saveToURL:fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler: ^ (BOOL success) {
            BOOL completed;
            
            if (success) {
                NSFileManager *manager = [NSFileManager defaultManager];
                NSURL *ubiquitousDirectory = [NSURL ubiquitousDocumentsDirectoryURL];
                NSURL *cloudURL = [ubiquitousDirectory URLByAppendingPathComponent:name];
                
                NSError *error = nil;
                [manager setUbiquitous:YES itemAtURL:fileURL destinationURL:cloudURL error:&error];
                
                if (!error) {
                    completed = YES;
                    document.cloudDocument = YES;
                    
                    MK_E_LOG(@"Created cloud document named %@", name);
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^ (void) {
                [self documentCreated:document success:completed]; 
            });
        }];
        
        [document release];
    });
}

- (void)openDocumentNamed:(NSString *)name content:(void(^)(id))content {
    self.openFileHandler = content;
    
    __block MKDocument *document = [self documentNamed:name];
        
    if (document) {
        [self openDocument:document]; 
    }
        
    else {
        MK_S_LOG(@"Searching for document named: %@", name);
        
        [self urlForFileNamed:name result: ^ (NSURL *result) { 
            if (result) {
                document = [[[MKDocument alloc] initWithFileURL:result] autorelease];
                document.cloudDocument = YES;
                
                [self openDocument:document];
            }
            else {
                NSString *directory = [NSString stringWithDocumentsDirectoryPath];
                NSString *path = [NSString stringWithFormat:@"%@/%@", directory, name];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    NSURL *documentDirectory = [NSURL documentsDirectoryURL];
                    NSURL *fileURL = [documentDirectory URLByAppendingPathComponent:name];
                
                    document = [[[MKDocument alloc] initWithFileURL:fileURL] autorelease];
                    document.cloudDocument = NO;
                    
                    [self openDocument:document];
                }
                else {
                    MK_E_LOG(@"Could not find document named: %@", name);
                    content(nil); 
                }
            }
        }];
    }
}

- (void)saveDocumentNamed:(NSString *)name successful:(void(^)(BOOL))successful {
    dispatch_queue_t backgournd = dispatch_queue_create("com.mkkit.document access thread", NULL);
    dispatch_async(backgournd, ^ (void) {
        MKDocument *document = [self documentNamed:name];
        
        [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler: ^ (BOOL success) {
            MK_E_LOG(@"Saved document named: %@", document.localizedName); 
        }];
        
    });
}

- (void)closeDocumentNamed:(NSString *)name successful:(void(^)(BOOL))successful {
    
}

#pragma mark - Cloud Operations

//---------------------------------------------------------------
// Cloud Operations
//---------------------------------------------------------------

- (void)pushDocumentToCloud:(MKDocument *)document named:(NSString *)name successful:(void (^)(BOOL))successful {
    self.pushFileHandler = successful;
    
    dispatch_async(backgroundqueue, ^ (void) {
        BOOL complete = NO;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];

        NSString *documentsDirectory = [NSString stringWithDocumentsDirectoryPath];
        NSString *path = [NSString stringWithFormat:@"%@/%@", documentsDirectory, name];
        
        if ([fileManager fileExistsAtPath:path]) {
            NSURL *cloudDirectory = [NSURL ubiquitousDocumentsDirectoryURL];
            NSURL *fileURL = [cloudDirectory URLByAppendingPathComponent:name];
            
            NSError *error = nil;
            [fileManager setUbiquitous:YES itemAtURL:document.fileURL destinationURL:fileURL error:&error];
            
            if (!error) {
                MK_E_LOG(@"Pushed document named %@", name);
                complete = YES;
                document.cloudDocument = YES;
            }
                        
            dispatch_async(dispatch_get_main_queue(), ^ (void) {
                [self documentAddedToCloud:document success:complete];
            });
        }
    });
}

- (void)removeDocumentNamed:(NSString *)name successful:(void(^)(BOOL))successful {
    self.removeFileHandler = successful;
    
    dispatch_async(backgroundqueue,  ^ (void) {
        BOOL complete = NO;
        
        NSURL *directoryURL = [NSURL documentsDirectoryURL];
        NSURL *fileURL = [directoryURL URLByAppendingPathComponent:name];
        
        NSURL *cloudDirectory = [NSURL ubiquitousDocumentsDirectoryURL];
        NSURL *cloudFileURL = [cloudDirectory URLByAppendingPathComponent:name];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSError *error = nil;
        [fileManager setUbiquitous:NO itemAtURL:cloudFileURL destinationURL:fileURL error:&error];
        
        if (!error) {
            MK_E_LOG(@"Removed document named: %@", name);
            complete = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^ (void) {
            MKDocument *document = [self documentNamed:name];
            document.cloudDocument = NO;
            
            [self removeDocument:document]; 
        });
    });
}

#pragma mark - Manage Documents

//---------------------------------------------------------------
// Manage Documents
//---------------------------------------------------------------

- (void)addDocument:(MKDocument *)document {
    if (!self.documents) {
        self.documents = [[NSMutableSet alloc] initWithCapacity:0];
    }
    
    NSInteger docCount = 0;
    
    for (MKDocument *doc in self.documents) {
        if ([document.localizedName isEqualToString:doc.localizedName]) {
            docCount = (docCount + 1);
        }
    }
    
    if (docCount == 0) {
        [self.documents addObject:document];
    }
    
    MK_S_LOG(@"Managed Document Count = %i", [self.documents count]);
}

- (void)removeDocument:(MKDocument *)document {
    if (document) {
        [self.documents removeObject:document];
    }
    
    MK_S_LOG(@"Managed Document Count = %i", [self.documents count]);
    
    if ([self.documents count] == 0) {
        [sharedCloud release]; sharedCloud = nil;
    }
}

//---------------------------------------------------------------
// Getting Documents
//---------------------------------------------------------------

- (MKDocument *)documentNamed:(NSString *)name {
    MKDocument *document = nil;
    
    for (MKDocument *doc in self.documents) {
        if ([doc.localizedName isEqualToString:name]) {
            document = doc;
        }
    }
    
    return document;
}

#pragma mark Load File

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

/*
#pragma mark Remove File

- (void)removeCloudFileNamed:(NSString *)name directory:(NSString *)directory successful:(void (^)(BOOL))successful {
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSURL *ubiq = [defaultManager URLForUbiquityContainerIdentifier:nil];
    NSURL *ubiqPackage = nil;
    
    if (directory) {
        ubiqPackage = [[ubiq URLByAppendingPathComponent:directory] URLByAppendingPathComponent:name];
    }
    else {
        ubiqPackage = [ubiq URLByAppendingPathComponent:name];
    }
    
    NSError *removeError;
    [defaultManager removeItemAtURL:ubiqPackage error:&removeError];
    
    if (removeError) {
        successful(NO);
    }
    else {
        successful(YES);
    }
}
*/
#pragma mark - Notifications

//---------------------------------------------------------------
// Notifications
//---------------------------------------------------------------

#pragma mark Query Results

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

#pragma mark Moved To Backgound

- (void)movedToBackground:(NSNotification *)notification {
    [sharedCloud release], sharedCloud = nil;
}

#pragma mark - Document Events

- (void)documentCreated:(MKDocument *)document success:(BOOL)success {
    if (success) {
        [self addDocument:document];
    }
        
    if (self.createFileHandler) {
        self.createFileHandler(success);
    }
}

- (void)documentAddedToCloud:(MKDocument *)document success:(BOOL)success {
    if (success) {
        [self addDocument:document];
    }
    
    if (self.pushFileHandler) {
        self.pushFileHandler(success);
    }
}

- (void)documentRemoved:(MKDocument *)document success:(BOOL)success {
    if (self.removeFileHandler) {
        self.removeFileHandler(success);
    }
}

- (void)openDocument:(MKDocument *)document {
    [document openWithCompletionHandler: ^ (BOOL successful) {
        if (successful) {
            self.openFileHandler(document.content);
            
            MK_E_LOG(@"Opened document named %@", document.localizedName);
            
            [self addDocument:document];
        } 
    }];
}

@end

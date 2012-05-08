//
//  MKCloud.h
//  MKKit
//
//  Created by Matthew King on 2/25/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>

#import "MKObject.h"

@class MKDocument;

/**--------------------------------------------------------------------------
 *Overview*
 
 MKCloud provides functions to easly manage documents in and out of the Cloud.
 MKCloud creats a singleton instance to manage your apps documents. Documents
 can be created, saved, closed, deleted, as well as pushed and pulled from the
 Cloud. The singleton also retains all open documents for fast retreaval. 
 
 *Usage*
 
 MKCloud is desinged to work as singleton. You can access the singleton by calling
 the `cloudManager` class method. The singleton does most of its work on a
 background thread. The threading is built in so all methods should be called from
 the main thread. All blocks passed to MKCloud are performed on the main thread.
 
 When using MKCloud documents are referenced by name. The expected name is the 
 same as the file name used when creating the document.  Be sure not to confuse
 the name with the documents `display name`. 
 
 The singleton controls the retention/release of documents automatically. By 
 all documents that are created or opened by the singleton are retained until
 they are closed. Documents can added or removed manually by calling the 
 addDocument: or removeDocument: methods.
 
 *Document Types*
 
 MKCloud only supports documents from the MKDocuments subclass. All documents
 created by MKCloud are created using this subclass. See MKDocuments for more
 information.
 
 *Addtional Information*
 
 MKCloud supports the default Debug/Event loggin of MKKit. You can toggle what
 type of logging you want to use from the `MKAvailability.h` file.
---------------------------------------------------------------------------*/

@interface MKCloud : MKObject {
@private
    NSMetadataQuery *mQuery;
    dispatch_queue_t backgroundqueue;
}

///-------------------------------
/// @name Getting Instances
///-------------------------------

/**
 Returns a singleton instance of MKCloud.
 
 This should be the only method used to get an instance. Creating instances
 yourself may degrade the preformance of Cloud documents.
 
 @return MKCloud instance
*/
+ (id)cloudManager;

///-------------------------------
/// @name Availability
///-------------------------------

/**
 Checks if iCloud is available for the current device/user. Returns `YES` if 
 available, `NO` if not.
*/
+ (BOOL)iCloudIsAvailable;

/** Retuns `YES` if iCloud is available, `NO` if it is not */
@property (readonly) BOOL cloudIsAvailable;

///-------------------------------
/// @name Manage Documents
///-------------------------------

/**
 Adds an instance MKDocument for the singleton to mangage. It is usually not
 required to add a document manually. The singleton instance manages the 
 retention/release of docuemnts automatically.
 
 @param document an instance of MKDocument
*/
- (void)addDocument:(MKDocument *)document;

/**
 Removes an instance MKDocument from the singletons management. It is usually not
 required to remove a document manually. The singleton instance manages the 
 retention/release of docuemnts automatically.
 
 @param document an instance of MKDocument
*/
- (void)removeDocument:(MKDocument *)document;

///-------------------------------
/// @name Getting Documents
///-------------------------------

/**
 Returns an instance of MKDocument if it is currently being managed by MKCloud, or 
 `nil` if not.
 
 @param name the file name of the document
 
 @return MKDocument instance or `nil`
*/
- (MKDocument *)documentNamed:(NSString *)name;

/**
 A set of all documents currently being managed by MKCloud.
*/
@property (retain) NSMutableSet *documents;

///-------------------------------
/// @name Document Operations
///-------------------------------

#if NS_BLOCKS_AVAILABLE

/**
 Creates a document with given name and content. By default this method pushes the document
 to the cloud after it is created. If you do not want the document to be on the cloud call 
 the removeDocumentNamed:successful: method in the successful block of this method.
 
 The document instance created here are automatically retained by the singleton.
 
 @param name the file name of the document
 
 @param content the content of the document in the form of an NSData instance
 
 @param successful the code block that is called upon completion of this method
*/
- (void)createDocumentNamed:(NSString *)name content:(NSData *)content successful:(void(^)(BOOL successful))successful;

/**
 Opens the document that has the given file name. This method will add a document
 the singletons managed documents if it is not already there. This method works in 
 three stages:
 
 1. Check for existing documents in the manager and uses them if availble.
 
 2. Seaches the devices cloud directories for the document and returns it when found.
 
 3. Look for the document in apps local documents directory and returns it when found.
 
 @param name the file name of the document
 
 @param localCopy `YES` if the manager should open a document that is stored on the device
 locally. `NO` to look for the document on the cloud.
 
 @param content the content of the document
 
 @warning *Note* The content will always be an instance of NSData when retuned in the 
 content block. Content will `nil` if no document could be found.
*/
- (void)openDocumentNamed:(NSString *)name localCopy:(BOOL)localCopy content:(void(^)(id content))content;

/**
 Saves the document that has the given file name. This method assumes the document being
 saved is currently being managed by the singleton.
 
 @param name the file name of the document
 
 @param successful code block called when the save is complete
*/
- (void)saveDocumentNamed:(NSString *)name successful:(void(^)(BOOL successful))successful;

/**
 Closes the docuemnt that has the given file name. This method assums the document being
 closed if currenetly being manged by the singleton. The singleton will remove the docuemnt
 from its managed list when the closing is complete.
 
 @param name the file name of the document
 
 @param successful the block called when the closing is complete
*/
- (void)closeDocumentNamed:(NSString *)name successful:(void(^)(BOOL sucessful))successful;

///-------------------------------
/// @name Cloud Operations
///-------------------------------

/**
 Pushes a document to the cloud and adds it to the singletons managed list if it is not
 already part of the docuemnts being managed.
 
 @param document the document to push to the cloud
 
 @param name the file name of the docuemnt
 
 @param successful the block called when the closing is complete
*/
- (void)pushDocumentToCloud:(MKDocument *)document named:(NSString *)name successful:(void(^)(BOOL successful))successful; 

/**
 Pulls the document off of the cloud and creates a copy in the apps documents directory.
 After the local copy of the document is created it can be opened using the openDocumentNamed:localCopy:successful:
 method, and passing `YES` to the localCopy parameter.
 
 @param name the name of the document to pull from the cloud
 
 @param successful the block to call when the operation is finished.
*/
- (void)pullDocumentNamed:(NSString *)name successful:(void(^)(BOOL successful))successful;

/**
 Removes the document off of the cloud and moves it to the apps documents directory. The 
 document will still be managed by the singleton after it is pulled from the cloud.
 
 @param name the file name of the document
 
 @param successful the block called when the movement is complete
*/
- (void)removeDocumentNamed:(NSString *)name successful:(void(^)(BOOL successful))successful;

///-------------------------------
/// @name Finding Documents
///-------------------------------

/**
 Checks if the given file exists in the local cloud directory and retuns an NSURL 
 instance if the file exists.
 
 @param name the name of the file to search for
 
 @param result the block to excute when the file is found.
*/
- (void)urlForFileNamed:(NSString *)name result:(void(^)(NSURL *fielURL))result;

#endif

@end

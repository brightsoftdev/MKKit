//
//  MKDocument.h
//  MKKit
//
//  Created by Matthew King on 3/28/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import <UIKit/UIKit.h>

/**-------------------------------------------------------------------
 *Overview*
 
 MKDocument is a subclass of UIDocument. It is used with MKCloud for 
 managment of documents on and off of the cloud. MKDocument can also
 be used as a stand-alone instance.
 
 *Usage*
 
 MKDocument expects its content to be in the form of an NSData instance.
 All content provide or retuned from the document should be in this form
 
 *Addtional Information*
 
 MKDocument supports the default Debug/Event login of MKKit. You can 
 toggle what type of lodding you want to use from the `MKAvailability.h` 
 file.
--------------------------------------------------------------------*/

@interface MKDocument : UIDocument

///--------------------------------
/// @name Accessing content
///--------------------------------

/** The content of the document in the form of an NSData instance. */
@property (nonatomic, retain) NSData *content;

///--------------------------------
/// @name Availability
///--------------------------------

/** 
 Tells if the documnet is availble to the cloud or not. `YES` for
 available, `NO` if not.
*/
@property (nonatomic, assign) BOOL cloudDocument;

@end

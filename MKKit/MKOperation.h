//
//  MKOperation.h
//  MKKit
//
//  Created by Matthew King on 2/18/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MKOperationDidStart,
    MKOperationDidCancel,
    MKOperationDidFinish,
} MKOpertaionEvent;

/**-----------------------------------------------------------------------------
 *Overview*
 
 MKOperation provides a base for an operation designed to be added to a NSOperationQueue.
 MKOperation is designed to be used as a superclass methods are provide to preform a
 process and send messges back to a target on the main thread. 
 
 *Usage*
 
 When you create an instance of MKOperation you can pass an object, this should be the
 object that you need to preform actions with.  You also provide a target and selector
 that will be a called on the main thread when when the process is complete. 
 
 Your subclass is required to overide one method:
 
 * `- (void)processObject:(id)object result:(void (^)(id rtnObject))result`
 
 This method is called by the main method to preform your process. The object parameter
 passes the object you assigned at the creation of the instance. Preform the need function
 of in this method return the object -- or nil if your main thread does not need the object
 back -- though the result block. Calling the result block cause the `MKOperationDidFinish`
 event selector to be called on the main thread.
 
 MKOperation also sends messages to the main thread during key phases of the operation.
 There are three events that trigger a message to be sent to the main thread:
 
 * `MKOperationDidStart` : sent when an operation starts to preform its process.
 * `MKOperationDidCancel` : sent when an operation is canceled.
 * `MKOperationDidFinish` : sent when an operation is finished.
 
 Use the addTarged:mainThreadCallBack:event: method to add targets and selectors
 to resopnd the needed event. 
 
 The selector is expected to be in a `-(void)someSelector:(id)object` format. For
 start and cancel events the object provide at creation is passed through the call
 back selector. For finish events the object is the object that is passed throught
 the result block of the processObject:result: method.
 
 @warning *Note* The target and selector that is provide throught the 
 initWithObject:target:mainThreadCallBack: method is assigned to the 
 `MKOperationDidFinishEvent`.
 
 *Responding to Cancel*
 
 MKOperation instances to preform any canceling actions, other than sending the 
 `MKOperationDidCancel` event selector to the main thread.  Cancelations need to 
 be handeled by subclasses.  
------------------------------------------------------------------------------*/

@interface MKOperation : NSOperation {
@private
    NSMutableSet *mTargets;
}

///------------------------------------------
/// @name Creating
///------------------------------------------

/**
 Creates a new instance of MKOperation and assign a selector for the `MKOperationDidFinish`
 event.
 
 @param object the object to preform the operation on.
 
 @param target a object that will recive the `MKOperationDidFinish` call back. This object
 must be on the main thread.
 
 @param callBack the selector to call when the operation is finished. The expected format is
 `-(void)someSelector:(id)someObject`
 
 @return MKOperation instance
*/
- (id)initWithObject:(id)object target:(id)target mainThreadCallBack:(SEL)callBack;

///------------------------------------------
/// @name Process Object
///------------------------------------------

/** Reference to the object that operation will use to preform its functions. */
@property (retain) id object;

/** 
 Preforms the needed process of the operation. Override this method and place
 your code here to preform the needed operation. Subclasses must call the 
 result block upon the completion of this method. If the result block is not
 called the `MKOperationDidFinish` event selector will not be called.
 
 @warning *Note* Subclass must overide this method and call the result block.
 Default implemtaion does nothing.
 
 @param object the object assigned during creation of the instance.
 
 @param result a code block that informs the main method that your operations
 have been completed.
*/
- (void)processObject:(id)object result:(void (^)(id rtnObject))result;

///------------------------------------------
/// @name Call Back 
///------------------------------------------

/**
 Adds a selector to be called during a specified event. All targets and selectors passed
 need to be availible on the main thread.
 
 @param target the object that will recive notice of an event.
 
 @param callBack the selector to call when the event occurres.
 
 @param event the event the trigers the call to the callBack selector.
*/
- (void)addTarget:(id)target mainThreadCallBack:(SEL)callBack event:(MKOpertaionEvent)event;

@end

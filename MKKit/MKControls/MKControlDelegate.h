//
//  MKControlDelegate.h
//  MKKit
//
//  Created by Matthew King on 9/28/10.
//  Copyright 2010-2011 Matt King All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MKKit/MKKit/MKMacros.h>

typedef enum {
    MKActionTouchDown,
    MKActionTouchUp,
    MKActionValueChanged,
    MKActionValueIncreased,
    MKActionValueDecreased,
} MKAction;

/**-------------------------------------------------------------------------------------------
 The MKControlDelegate protocol sends genaric messages from MKControl subclasses.
--------------------------------------------------------------------------------------------*/

@protocol MKControlDelegate <NSObject> 

@optional

///-------------------------------------------------------------------------------------------
/// @name Completion Methods
///-------------------------------------------------------------------------------------------

/** Called whenever an action has been completed.
 
 @param action The MKAction that was completed.
 @param sender The control that completed the action.
*/
- (void)didCompleteAction:(MKAction)action sender:(id)sender;

@end
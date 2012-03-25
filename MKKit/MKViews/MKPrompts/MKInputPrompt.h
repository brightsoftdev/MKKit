//
//  MKInputPrompt.h
//  MKKit
//
//  Created by Matthew King on 5/18/11.
//  Copyright 2011-2012 Matt King. All rights reserved.
//

#import "MKPromptView.h"

/**----------------------------------------------------------------------------------------
 The MKInputPrompt class provides a pop-over text input prompt. The input prompt includes
 space for a message to the user. MKInputPrompt will automatically adjust it's hieght to
 fit the entire message. 
-----------------------------------------------------------------------------------------*/

@interface MKInputPrompt : MKPromptView <UITextFieldDelegate> {
    UITextField *mTextField;
}

///--------------------------------------------------------------------------------------
/// @name Creating
///--------------------------------------------------------------------------------------

/**
 Returns and initalized instance of MKInputPrompt. When this method is use it is your responsiblity
 to display/remove the prompt, and handel the inputed text. For automatic display and input handeling
 use showWithMessage:onDone:.
 
 @param message the message the message to display to the user.
*/
- (id)initWithMessage:(NSString *)message;

/**
 Creates and displays an instance of MKInputPrompt with an onDone code block. When using this 
 method the view is displayed using `MKViewAnimationTypeMoveInFromTop`. 
 
 @param message the message the message to display to the user.
 
 @param completionBlock the block of code to preform when the Done button is touched.
*/
+ (void)showWithMessage:(NSString *)message onDone:(void(^)(NSString *text))completionBlock;

///--------------------------------------------------------------------------------------
/// @name Elements
///--------------------------------------------------------------------------------------

/** The text field on the prompt. */
@property (nonatomic, retain) UITextField *textField;

@end

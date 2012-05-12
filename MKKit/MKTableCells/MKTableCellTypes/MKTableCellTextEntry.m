//
//  MKTableCellTextEntry.m
//  MKKit
//
//  Created by Matthew King on 11/1/10.
//  Copyright 2010 Matt King. All rights reserved.
//

#import "MKTableCellTextEntry.h"
#import "MKDeffinitions.h"

//---------------------------------------------------------------
// Interface
//---------------------------------------------------------------

@interface MKTableCellTextEntry ()

- (void)textChanged:(id)sender;
- (void)warningIcon:(id)sender;
- (void)pickerPosted;

@end

//---------------------------------------------------------------
// Implementaion
//---------------------------------------------------------------

@implementation MKTableCellTextEntry

@synthesize theTextField=mTheTextField, textEntryType=mTextEntryType;

//---------------------------------------------------------------
// Creation
//---------------------------------------------------------------

#pragma mark - Creation

- (id)initWithType:(MKTextEntryCellType)cellType reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithType:MKTableCellTypeNone reuseIdentifier:reuseIdentifier];
    if (self) {
        mTextEntryType = cellType;
        
        mCellView = [[MKView alloc] initWithCell:self];
        
        mTheTextField = [[MKTextField alloc] initWithFrame:CGRectZero];
		mTheTextField.textAlignment = UITextAlignmentCenter;
        mTheTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		mTheTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		mTheTextField.delegate = self;
		mTheTextField.returnKeyType = UIReturnKeyDone;
		mTheTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
		
		[mTheTextField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
        
        if (cellType == MKTextEntryCellTypeFull) {
            [mCellView addPrimaryElement:mTheTextField];
            
            mTheLabel.hidden = YES;
            [mTheLabel removeFromSuperview];
        }
        
        if  (cellType == MKTextEntryCellTypeStandard) {
            mTheLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            mTheLabel.textAlignment = UITextAlignmentLeft;
            mTheLabel.adjustsFontSizeToFitWidth = YES;
            mTheLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
            mTheLabel.backgroundColor = [UIColor clearColor];
            
            [mCellView addPrimaryElement:mTheLabel];
            [mCellView addSecondaryElement:mTheTextField];
            
            [mTheLabel release];
        }
        
		[mTheTextField release];
        
        [self.contentView addSubview:mCellView];
        [mCellView release];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pickerPosted) name:PICKER_DID_SHOW_NOTIFICATION object:nil]; 
    }
    return self;
}

//---------------------------------------------------------------
// Memory
//---------------------------------------------------------------

#pragma mark - Memory Managment

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PICKER_DID_SHOW_NOTIFICATION object:nil];
    
    self.theTextField = nil;
    
    if (mValidationError) {
        mValidationError = nil;
        [mValidationError release];
    }
    
    [super dealloc];
}

//---------------------------------------------------------------
// Selection
//---------------------------------------------------------------

#pragma mark - Selection

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

	if (selected) {
		[self.theTextField becomeFirstResponder];
		if ([delegate respondsToSelector:@selector(textFieldIsFirstResponder:)]) {
			[delegate textFieldIsFirstResponder:self.theTextField];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:PICKER_SHOULD_DISMISS_NOTIFICATION object:self];
	}
	if (!selected) {
		[self.theTextField resignFirstResponder];
    }	
}

//---------------------------------------------------------------
// Accessors
//---------------------------------------------------------------

- (CGFloat)secondaryElementWidth {
    return (mCellView.width - 125.0);
}

//---------------------------------------------------------------
// Validation
//---------------------------------------------------------------

#pragma mark - Validation Methods

- (BOOL)validatedWithType:(MKValidationType)aType {
    BOOL validated = YES;
    
    NSMutableDictionary *errorInfo = [[NSMutableDictionary alloc] initWithCapacity:3];
    [errorInfo setObject:self.theTextField forKey:MKValidatorField];
    if (self.theTextField.text) {
        [errorInfo setObject:self.theTextField.text forKey:MKValidatorEnteredText];
    }
    
	if (aType == MKValidateIsaNumber) {
		if ([validator respondsToSelector:@selector(inputIsaNumber:)]) {
			if (![validator inputIsaNumber:self.theTextField.text]) {
				mValidationError = [NSError errorWithDomain:ERROR_DESCRIPTION_701 code:ERROR_CODE_701 userInfo:errorInfo];
                validated = NO;
			}
		}
	}
    if (aType == MKValidateIsaSetLength) {
        if ([validator respondsToSelector:@selector(inputIsaSetLength:)]) {
            if (![validator inputIsaSetLength:self.theTextField.text]) {
                mValidationError = [NSError errorWithDomain:ERROR_DESCRIPTION_703(mValidatorTestStringLength) code:ERROR_CODE_703 userInfo:errorInfo];
                validated = NO;
            }
        }
    }
	if (aType == MKValidateHasLength) {
		if ([validator respondsToSelector:@selector(inputHasLength:)]) {
			if (![validator inputHasLength:self.theTextField.text]) {
				mValidationError = [NSError errorWithDomain:ERROR_DESCRIPTION_702 code:ERROR_CODE_702 userInfo:errorInfo];
                validated = NO;
            }
		}
	}
    
    [errorInfo release];
    
    if ([delegate respondsToSelector:@selector(cellDidValidate:forKey:indexPath:)]) {
        [delegate cellDidValidate:mValidationError forKey:self.key indexPath:self.indexPath];
    }
    
    return validated;
}

//---------------------------------------------------------------
// Actions
//---------------------------------------------------------------

#pragma mark - Actions

- (void)textChanged:(id)sender {
	if ([delegate respondsToSelector:@selector(valueDidChange:forKey:)]) {
		[delegate valueDidChange:self.theTextField.text forKey:self.key];
	}
}

- (void)warningIcon:(id)sender {
	if (mValidationError) {
		MKErrorHandeling *handeler = [[MKErrorHandeling alloc] init];
		[handeler applicationDidError:mValidationError];
		[handeler release];
	}
}

//---------------------------------------------------------------
// Delegate
//---------------------------------------------------------------

#pragma mark - Delegate
#pragma mark TextField

- (void)textFieldDidEndEditing:(UITextField *)textField {		
	if ([delegate respondsToSelector:@selector(valueDidChange:forKey:)]) {
		[delegate valueDidChange:textField.text forKey:self.key];
	}
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self setSelected:YES animated:YES];
	if ([delegate respondsToSelector:@selector(textFieldIsFirstResponder:)]) {
		[delegate textFieldIsFirstResponder:textField];
	}
	
	if (mValidationError) {
		self.accessoryView = UITableViewCellAccessoryNone;
		mValidationError = nil;
		[mValidationError release];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

//---------------------------------------------------------------
// Observations
//---------------------------------------------------------------

#pragma mark - Observer Methods

- (void)pickerPosted {
	[self.theTextField resignFirstResponder];
}

@end
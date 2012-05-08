//
//  MKTableCellTextView.m
//  MKKit
//
//  Created by Matthew King on 11/6/10.
//  Copyright 2010-2012 Matt King. All rights reserved.
//

#import "MKTableCellTextView.h"

//---------------------------------------------------------------
// Interface
//---------------------------------------------------------------

@interface MKTableCellTextView ()

- (void)clearTextView:(id)sender;
- (void)resignTextView:(id)sender;

@end

//---------------------------------------------------------------
// Implementaion
//---------------------------------------------------------------

@implementation MKTableCellTextView

@synthesize theTextView=mTheTextView;

//---------------------------------------------------------------
// Creation
//---------------------------------------------------------------

#pragma mark - Creation

- (id)initWithType:(MKTableCellType)cellType reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithType:MKTableCellTypeNone reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect textViewFrame = CGRectMake(5.0, 6.0, 285.0, 73.0);
		
		mTheTextView = [[UITextView alloc] initWithFrame:textViewFrame];
		mTheTextView.editable = YES;
		mTheTextView.delegate = self;
        mTheTextView.backgroundColor = CLEAR;
		mTheTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
		
		[self.contentView addSubview:mTheTextView];
		[mTheTextView release];
    }
    return self;
}

//---------------------------------------------------------------
// Memory
//---------------------------------------------------------------

#pragma mark - Memory Managment

- (void)dealloc {
    //self.theTextView = nil;
    
    [super dealloc];
}

//---------------------------------------------------------------
// Selection
//---------------------------------------------------------------

#pragma mark - Selection

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//---------------------------------------------------------------
// Text View Contol
//---------------------------------------------------------------

#pragma mark - Text View Control

- (void)clearTextView:(id)sender {
	self.theTextView.text = @"";
}

- (void)resignTextView:(id)sender {
	if ([delegate respondsToSelector:@selector(valueDidChange:forKey:)]) {
		[delegate valueDidChange:self.theTextView.text forKey:self.key];
	}
	
	[self.theTextView resignFirstResponder];
}

//---------------------------------------------------------------
// Delegates
//---------------------------------------------------------------

#pragma mark - Delegates
#pragma mark TextView 

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)];
	toolBar.barStyle = UIBarStyleBlackOpaque;
	
	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearTextView:)];
	UIBarButtonItem *doneTabButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(resignTextView:)];
	
	NSArray *items = [[NSArray alloc] initWithObjects:space, clearButton, doneTabButton, nil];
	
	[toolBar setItems:items animated:NO];
	
	[space release];
	[clearButton release];
	[doneTabButton release];
	
	[items release];
	
	textView.inputAccessoryView = toolBar;
	
	[toolBar release];
	return YES;
}

@end

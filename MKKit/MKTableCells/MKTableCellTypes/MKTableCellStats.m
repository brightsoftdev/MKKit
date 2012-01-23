//
//  MKTableCellStats.m
//  MKKit
//
//  Created by Matthew King on 10/20/10.
//  Copyright 2010-2012 Matt King. All rights reserved.
//

#import "MKTableCellStats.h"


@implementation MKTableCellStats

#pragma mark -
#pragma mark Initalizer

- (id)initWithType:(MKTableCellType)cellType reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithType:MKTableCellTypeNone reuseIdentifier:reuseIdentifier];
    if (self) {
		//CGRect labelRect = CGRectMake(10.0, 11.0, 150.0, 21.0);
		//CGRect smallFrame = CGRectMake(190.0, 11.0, 100.0, 21.0);
        
        mCellView = [[MKView alloc] initWithCell:self];
        [self.contentView addSubview:mCellView];
        [mCellView release];
		
		mTheLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		mTheLabel.adjustsFontSizeToFitWidth = YES;
		mTheLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		mTheLabel.backgroundColor = [UIColor clearColor];
		mTheLabel.textAlignment = UITextAlignmentLeft;
		mTheLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:16.0];
		
		[mCellView addPrimaryElement:mTheLabel];
        [mTheLabel release];
		
		mSmallLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        mSmallLabel.backgroundColor = CLEAR;
		mSmallLabel.textAlignment = UITextAlignmentRight;
		mSmallLabel.adjustsFontSizeToFitWidth = YES;
		mSmallLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:16.0];
		mSmallLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
		
		[mCellView addSecondaryElement:mSmallLabel];
		[mSmallLabel release];
    }
    return self;
}

#pragma mark -
#pragma mark Cell Behavior

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [super dealloc];
}


@end

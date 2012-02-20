//
//  MKTableCellSwitch.m
//  MKKit
//
//  Created by Matthew King on 11/1/10.
//  Copyright 2010 Matt King. All rights reserved.
//

#import "MKTableCellSwitch.h"

@interface MKTableCellSwitch ()

- (void)switchFlipped:(id)sender;

@end

@implementation MKTableCellSwitch

@synthesize theSwitch=mTheSwitch;

#pragma mark - Creation

- (id)initWithType:(MKTableCellType)cellType reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithType:MKTableCellTypeNone reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect switchFrame = CGRectMake(198.3, 10.0, 172.0, 21.0);
        self.secondaryElementWidth = 100.0;
		
        mCellView = [[MKView alloc] initWithCell:self];
        
		mTheLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		mTheLabel.textAlignment = UITextAlignmentLeft;
		mTheLabel.adjustsFontSizeToFitWidth = YES;
		mTheLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		mTheLabel.backgroundColor = CLEAR;
		
        [mCellView addPrimaryElement:mTheLabel];
		[mTheLabel release];
		
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.tag = kSecondaryViewTag;
        
		mTheSwitch = [[UISwitch alloc] initWithFrame:switchFrame];
		[mTheSwitch addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
        mTheSwitch.on = NO;
        
        [view addSubview:mTheSwitch];
        [mTheSwitch release];
        
        [mCellView addSecondaryElement:view];
		[view release];
        
        [self.contentView addSubview:mCellView];
        [mCellView release];
    }
    return self;
}

#pragma mark - Layout

- (void)layoutForMetrics:(MKViewMetrics)metrics {
    UIView *switchView = [self.cellView viewWithTag:kSecondaryViewTag];
    
    MKMetrics *viewMetrics = [MKMetrics metricsForView:switchView];
    
    mTheSwitch.frame = CGRectMake((switchView.frame.size.width - 79.0), 0.0, 79.0, 27.0);
    
    [viewMetrics beginLayout];
    [viewMetrics horizontallyCenterView:mTheSwitch];
    [viewMetrics endLayout];
}

#pragma mark - Cell Behaivor

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

#pragma mark - SwitchCell Methods

- (void)switchFlipped:(id)sender {
	if ([delegate respondsToSelector:@selector(valueDidChange:forKey:)]) {
		NSNumber *pos = [NSNumber numberWithBool:self.theSwitch.on];
		[delegate valueDidChange:pos forKey:self.key];
	}
}

#pragma mark -
#pragma mark Memory Managment

- (void)dealloc {
    [super dealloc];
}



@end

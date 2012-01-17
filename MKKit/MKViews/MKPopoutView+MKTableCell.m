//
//  MKPopoutView+MKTableCell.m
//  MKKit
//
//  Created by Matthew King on 12/31/11.
//  Copyright (c) 2011-2012 Matt King. All rights reserved.
//

#import "MKPopoutView+MKTableCell.h"

#import <MKKit/MKKit/MKTableCells/MKTableCell.h>
#import <MKKit/MKKit/MKControls/MKButton.h>

static const char *IndexPathTag = "IndexPathTag";
static const char *TableViewTag = "TableViewTag";

@implementation MKPopOutView (MKTableCell)

@dynamic aIndexPath, tableView;

#pragma mark - Accessor Methods

- (UITableView *)tableView {
    return (UITableView *)objc_getAssociatedObject(self, TableViewTag);
}

- (NSIndexPath *)aIndexPath {
    return (NSIndexPath *)objc_getAssociatedObject(self, IndexPathTag);
}

#pragma mark - Displaying

- (void)showFromCell:(MKTableCell *)cell onView:(UITableView *)tableView {
    objc_setAssociatedObject(self, TableViewTag, tableView, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self, IndexPathTag, cell.indexPath, OBJC_ASSOCIATION_RETAIN);
    
    CGRect cellRect = [tableView rectForRowAtIndexPath:cell.indexPath];
    
    mAnimationType = MKViewAnimationTypeFadeIn;
    mPopOutType = MKPopOutTableCell;
    mArrowPosition = cell.center.x;
    
    self.tag = kMKPopOutViewTableCellTag;
    
    if (mType != MKPopOutAuto) {
        mAutoType = mType;
    }
    else {
        if (CGRectGetMaxY(cellRect) < (tableView.bounds.size.height - (mView.frame.size.height + 50.0))) {
            mAutoType = MKPopOutBelow;
        }
        else {
            mAutoType = MKPopOutAbove;
        }
    }
    
    if (mAutoType == MKPopOutBelow) {
        self.frame = CGRectMake(cellRect.origin.x, (cellRect.origin.y + cellRect.size.height), self.width, self.height);
        mView.frame = CGRectMake(10.0, 10.0, kPopOutViewWidth, mView.frame.size.height);
    }
    else if (mAutoType == MKPopOutAbove) {
        self.frame = CGRectMake(cellRect.origin.x, (cellRect.origin.y - self.frame.size.height), self.width, self.height);
        mView.frame = CGRectMake(0.0, 0.0, kPopOutViewWidth, mView.frame.size.height);
        
        [tableView scrollRectToVisible:self.frame animated:YES];
    }
    
    [self setNeedsDisplay];
    
    [tableView addSubview:self];
    [tableView scrollRectToVisible:self.frame animated:YES];
    
    [UIView animateWithDuration:0.25 
                     animations: ^ { self.alpha = 1.0; } ];
}

- (void)adjustToCell {
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:self.aIndexPath];
    MKTableCell *cell = (MKTableCell *)[self.tableView cellForRowAtIndexPath:self.aIndexPath];
    
    mArrowPosition = cell.center.x;
    self.tag = kMKPopOutViewTableCellTag;
    
    if (mType != MKPopOutAuto) {
        mAutoType = mType;
    }
    else {
        if (CGRectGetMaxY(cellRect) < (self.tableView.bounds.size.height - (mView.frame.size.height + 50.0))) {
            mAutoType = MKPopOutBelow;
        }
        else {
            mAutoType = MKPopOutAbove;
        }
    }
    
    if (mAutoType == MKPopOutBelow) {
        self.frame = CGRectMake(cellRect.origin.x, (cellRect.origin.y + cellRect.size.height), self.width, self.height);
        mView.frame = CGRectMake(10.0, 10.0, kPopOutViewWidth, mView.frame.size.height);
    }
    else if (mAutoType == MKPopOutAbove) {
        self.frame = CGRectMake(cellRect.origin.x, (cellRect.origin.y - self.frame.size.height), self.width, self.height);
        mView.frame = CGRectMake(0.0, 0.0, kPopOutViewWidth, mView.frame.size.height);
        
        [self.tableView scrollRectToVisible:self.frame animated:YES];
    }
    
    [self setNeedsDisplay];
    [self.tableView scrollRectToVisible:self.frame animated:YES];
}

#pragma mark - Elements

- (void)setDisclosureButtonWithTarget:(id)target selector:(SEL)selector {
    mView.frame = CGRectMake(mView.frame.origin.x, mView.frame.origin.y, (mView.frame.size.width - 33.0), mView.frame.size.height);
    
    MKButton *button = [[MKButton alloc] initWithType:MKButtonTypeDisclosure];
    button.center = CGPointMake((CGRectGetMaxX(self.frame) - 25.0), CGRectGetMidY(mView.frame));
    
    [button completedAction: ^ (MKAction action) {
        if (action == MKActionTouchUp) {
            [target performSelector:selector withObject:self.aIndexPath];
        }
    }];
    
    [self addSubview:button];
    [button release];
}

@end

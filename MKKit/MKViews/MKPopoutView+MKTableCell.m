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

@dynamic aIndexPath;

#pragma mark - Accessor Methods

- (NSIndexPath *)aIndexPath {
    return nil;
}

#pragma mark - Displaying

- (void)showFromCell:(MKTableCell *)cell onView:(UITableView *)tableView {
    objc_setAssociatedObject(self, TableViewTag, tableView, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self, IndexPathTag, cell.indexPath, OBJC_ASSOCIATION_RETAIN);
    
    CGRect cellRect = [tableView rectForRowAtIndexPath:cell.indexPath];
    
    mAnimationType = MKViewAnimationTypeFadeIn;
    mPopOutType = MKPopOutTableCell;
        
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
    
    [self adjustToCell];
    
    [UIView animateWithDuration:0.25 
                     animations: ^ { self.alpha = 1.0; } ];
}

- (void)adjustToCell {
    UITableView *tableView = (UITableView *)objc_getAssociatedObject(self, TableViewTag);
    NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(self, IndexPathTag);
   
    CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
    
    MKTableCell *cell = (MKTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        mArrowPosition = self.center.x;
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        CGPoint cellCenter = CGPointMake(CGRectGetMidX(cellRect), CGRectGetMidY(cellRect));
        mArrowPosition = [cell convertPoint:cellCenter toView:self].x;
    }
        
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
    [tableView scrollRectToVisible:self.frame animated:YES];
}

#pragma mark - Elements

- (void)setDisclosureButtonWithTarget:(id)target selector:(SEL)selector {
    NSIndexPath *indexPath = (NSIndexPath *)objc_getAssociatedObject(self, IndexPathTag);
    
    mView.frame = CGRectMake(mView.frame.origin.x, mView.frame.origin.y, (mView.frame.size.width - 33.0), mView.frame.size.height);
    
    MKButton *button = [[MKButton alloc] initWithType:MKButtonTypeDisclosure];
    button.center = CGPointMake((CGRectGetMaxX(self.frame) - 25.0), CGRectGetMidY(mView.frame));
    
    [button completedAction: ^ (MKAction action) {
        if (action == MKActionTouchUp) {
            [target performSelector:selector withObject:indexPath];
        }
    }];
    
    [self addSubview:button];
    [button release];
}

@end

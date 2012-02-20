//
//  MKOperation.m
//  MKKit
//
//  Created by Matthew King on 2/18/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKOperation.h"
#import "MKObject.h"

#import <MKKit/MKKit/MKErrorContol/MKErrorCodes.h>

@interface MKOpertaionTarget : MKObject 

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) MKOpertaionEvent event;
    
@end

@interface MKOperation ()

- (void)setFinishTarget:(id)target selector:(SEL)selector;
- (void)processComplete:(id)object;

- (void)sendEvent:(MKOpertaionEvent)event withObject:(id)object;

@end

@implementation MKOperation

@synthesize object;

#pragma mark - Creation

- (id)initWithObject:(id)_object target:(id)target mainThreadCallBack:(SEL)callBack {
    self = [super init];
    if (self) {
        if (_object) {
            self.object = [_object retain];
        }
        
        [self setFinishTarget:target selector:callBack];
    }
    return self;
}

- (void)setFinishTarget:(id)target selector:(SEL)selector {
    MKOpertaionTarget *opertaionTarget = [[MKOpertaionTarget alloc] init];
    opertaionTarget.target = target;
    opertaionTarget.selector = selector;
    opertaionTarget.event = MKOperationDidFinish;
    
    mTargets = [[NSMutableSet alloc] initWithCapacity:1];
    [mTargets addObject:opertaionTarget];
    
    [opertaionTarget release];
}

#pragma mark - Memory

- (void)dealloc {
    [mTargets release];
    
    [super dealloc];
}

#pragma mark - Targets

- (void)addTarget:(id)target mainThreadCallBack:(SEL)callBack event:(MKOpertaionEvent)event {
    MKOpertaionTarget *opertaionTarget = [[MKOpertaionTarget alloc] init];
    opertaionTarget.target = target;
    opertaionTarget.selector = callBack;
    opertaionTarget.event = event;
    
    [mTargets addObject:opertaionTarget];
    [opertaionTarget release];
}

- (void)sendEvent:(MKOpertaionEvent)event withObject:(id)_object {
    for (MKOpertaionTarget *target in mTargets) {
        if (target.event == event) {
            [target.target performSelectorOnMainThread:target.selector withObject:_object waitUntilDone:NO];
        }
    }

}

#pragma mark - Main

- (void)main {
    [self sendEvent:MKOperationDidStart withObject:self.object];
    [self processObject:self.object result: ^ (id rtnObject) { [self processComplete:rtnObject]; }];
}

- (void)processComplete:(id)_object {
    [self sendEvent:MKOperationDidFinish withObject:_object];
}

#pragma mark - Cancel Methods

- (void)cancel {
    [super cancel];
    
    [self sendEvent:MKOperationDidCancel withObject:self.object];
}

#pragma mark - Override Methods

- (void)processObject:(id)object result:(void (^)(id))result {
    /// For subclass overide
}

@end

#pragma mark - Operation Targets

@implementation MKOpertaionTarget

@synthesize target, selector, event;

@end

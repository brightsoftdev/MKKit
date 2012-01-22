//
//  MKSlideViewController.m
//  MKKit
//
//  Created by Matthew King on 1/20/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKDisclosureViewController.h"

#import <MKKit/MKKit/MKViewControllers/UIViewController+MKViewController.m>

CGRect adjustRectForMainView(CGRect rect, float uncoverDistance);
CGRect adjustRectForDisclosureView(CGRect rect, float uncoverDistance);

CGRect adjustRectForMainView(CGRect rect, float uncoverDistance) {
    float x = rect.origin.x;
    float y = rect.origin.y;
    float width = uncoverDistance;
    float height = rect.size.height;
    
    return CGRectMake(x, y, width, height);
}

CGRect adjustRectForDisclosureView(CGRect rect, float uncoverDistance) {
    float x = uncoverDistance;
    float y = 0.0;
    float width = (widthForMetrics(metricsForCurrentOrientation()) - uncoverDistance);
    float height = rect.size.height;
    
    return CGRectMake(x, y, width, height);
}

@interface MKDisclosureViewController ()

- (void)addShaddow:(float)x;

@end

@implementation MKDisclosureViewController

@synthesize mainViewController=mMainViewController, disclosureViewController=mdisclosureViewController, disclosureViewIsVisiable=mDisclosureViewIsVisible;

#pragma mark - Creation

- (id)initWithMainController:(UIViewController *)mainController disclosureController:(UIViewController *)disclosureController {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        mMainViewController = [mainController retain];
        mDisclosureViewController = [disclosureController retain];
        
        [self addChildViewController:mMainViewController];
        [self addChildViewController:mDisclosureViewController];
        
        [mMainViewController didMoveToParentViewController:self];
        [mDisclosureViewController didMoveToParentViewController:self];
    }
    return self;
}

#pragma mark - Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [mMainViewController release];
    [mDisclosureViewController release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.view = view;
    [view release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [mMainViewController viewWillAppear:NO];
    
    mMainViewController.view.frame = self.view.frame;
    [self.view addSubview:mMainViewController.view];
    
    [mMainViewController viewDidAppear:NO];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark - Rotaion

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
    return YES;
}

#pragma mark - Accessor Methods
#pragma mark Getters

- (UIViewController *)mainViewController {
    return mMainViewController;
}

- (UIViewController *)disclosureViewController {
    return mDisclosureViewController;
}

- (BOOL)disclosureViewIsVisiable {
    return mDisclosureViewIsVisible;
}

#pragma mark - Transition Control

- (void)uncoverByDistance:(float)distance {
    [mDisclosureViewController viewWillAppear:YES];
    
    [self.view insertSubview:mDisclosureViewController.view belowSubview:mMainViewController.view];
    
    mDisclosureViewController.view.frame = CGRectMake(self.view.frame.size.width, 0.0, self.view.frame.size.width, self.view.frame.size.height);
    mDisclosureViewController.view.alpha = 0.0;
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionLayoutSubviews
                     animations: ^ (void) {
                         mMainViewController.view.frame = adjustRectForMainView(self.view.frame, distance);
                         mDisclosureViewController.view.alpha = 1.0;
                         mDisclosureViewController.view.frame = adjustRectForDisclosureView(self.view.frame, distance);
                     }
                     completion: ^ (BOOL finished) {
                         [mDisclosureViewController viewDidAppear:YES];
                         mDisclosureViewIsVisible = YES;
                         
                         [mDisclosureViewController didDiscloseView];
                         [mMainViewController didDiscloseView];
                         
                         [self addShaddow:distance];
                     }];
}

- (void)fullyUncover {
    [self uncoverByDistance:0.0];
}

- (void)recover {
    
}

#pragma mark - Accenting

- (void)addShaddow:(float)_x {
    float x = (_x - 1.0);
    float y = 0.0;
    float width = 3.0;
    float height = mMainViewController.view.frame.size.height;
    
    MKShadowView *shadowView = [[MKShadowView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [self.view addSubview:shadowView];
    [self.view bringSubviewToFront:shadowView];
    [shadowView release];
}

@end

@implementation MKShadowView

#pragma mark - Creation

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = CLEAR;
    }
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    
    CGContextSetShadowWithColor(context, CGSizeMake(-1.0, 0.0), 3.0, MK_SHADOW_COLOR);
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, BLACK.CGColor);
    CGContextMoveToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextStrokePath(context);
}

@end
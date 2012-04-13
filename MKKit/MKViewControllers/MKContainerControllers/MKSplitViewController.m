//
//  MKSplitViewController.m
//  MKKit
//
//  Created by Matthew King on 1/29/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKSplitViewController.h"

//---------------------------------------------------------------
// Functions
//---------------------------------------------------------------

CGRect rectForListView(MKViewMetrics metrics, BOOL hasTabBar);
CGRect rectForListNavigationBar(void);

CGRect rectForDetailNavigationBar(MKViewMetrics metrics);
CGRect rectForDetailView(MKViewMetrics metrics, BOOL hasTabBar);

CGRect startRectForListTransition(MKViewMetrics metrics, BOOL hasTabBar);
CGRect startRectForListNavigationBarTransition(void);

#pragma mark - Helpers
#pragma mark List View

CGRect rectForListView(MKViewMetrics metrics, BOOL hasTabBar) {
    CGFloat height = MKMetricsHeightForMetrics(metrics) - 44.0;
    
    if (hasTabBar) {
        height = height - 49.0;
    }
    
    return CGRectMake(0.0, 44.0, 320.0, height);
}

CGRect rectForListNavigationBar(void) {
    return CGRectMake(0.0, 0.0, 320.0, 44.0);
}

#pragma mark Detail View

CGRect rectForDetailNavigationBar(MKViewMetrics metrics) {
    CGFloat width = 0.0;
    CGFloat x = 0.0;
    
    if (metrics == MKMetricsLandscape) {
        width = 704.0;
        x = 320.0;
    }
    else {
        width = MKMetricsWidthForMetrics(MKMetricsPortrait);
    }
    
    return CGRectMake(x, 0.0, width, 44.0);
}

CGRect rectForDetailView(MKViewMetrics metrics, BOOL hasTabBar) {
    CGFloat width = 0.0;
    CGFloat x = 0.0;
    CGFloat height = MKMetricsHeightForMetrics(metrics) - 44.0;
    
    if (metrics == MKMetricsLandscape) {
        width = 704.0;
        x = 320.0;
    }
    else {
        width = MKMetricsWidthForMetrics(MKMetricsPortrait);
    }
    
    if (hasTabBar) {
        height = height - 49.0;
    }
    
    return CGRectMake(x, 44.0, width, height);
}

#pragma mark Transitions

CGRect startRectForListTransition(MKViewMetrics metrics, BOOL hasTabBar) {
    CGFloat height = MKMetricsHeightForMetrics(metrics) - 44.0;
    
    if (hasTabBar) {
        height = height - 49.0;
    }
    
    return CGRectMake(-320.0, 44.0, 320.0, height);
}

CGRect startRectForListNavigationBarTransition(void) {
    return CGRectMake(-320.0, 0.0, 320.0, 44.0);
}

#pragma mark - Views

//---------------------------------------------------------------
// Interfaces
//---------------------------------------------------------------

@interface MKSplitView : MKView {
@private
    
}

- (void)addListNavigationBar;
- (void)addDetailNavigationBar;

@end

typedef enum {
    MKDividerViewSplit,
    MKDividerViewOverlap,
} MKDividerViewType;

@interface MKDividerView : MKView {
@private
    MKDividerViewType type;
}

- (id)initWithFrame:(CGRect)frame type:(MKDividerViewType)type;

@end

#pragma mark - Controller

@interface MKSplitViewController ()

- (void)viewsForMetrics:(MKViewMetrics)metrics inital:(BOOL)inital;
- (void)backButton:(id)sender;
- (void)listButton:(id)sender;

- (void)addListShaddow;

@end

//---------------------------------------------------------------
// Implenentaions
//---------------------------------------------------------------

@implementation MKSplitViewController

@dynamic listViewController, detailViewController, listViewIsVisable;

#pragma mark - Creation

//---------------------------------------------------------------
// Creation
//---------------------------------------------------------------

- (id)initWithListViewController:(UIViewController *)listViewController detailViewController:(UIViewController *)detailViewController {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        mListViewController = [listViewController retain];
        mDetailViewController = [detailViewController retain];
        
        [self addChildViewController:mListViewController];
        [self addChildViewController:mDetailViewController];
        
        [mListViewController didMoveToParentViewController:self];
        [mListViewController didMoveToParentViewController:self];
    }
    return self;
}

#pragma  mark - Memory

//---------------------------------------------------------------
// Memory
//---------------------------------------------------------------

- (void)dealloc {
    [mListViewController release];
    [mDetailViewController release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

//---------------------------------------------------------------
// View LifeCycle
//---------------------------------------------------------------

- (void)loadView {
    MKSplitView *splitView = [[MKSplitView alloc] initWithFrame:CGRectZero];
    splitView.controller = self;
    self.view = splitView;
    [splitView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self viewsForMetrics:MKMetricsCurrentOrientationMetrics() inital:YES];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [mListViewController.view removeFromSuperview];
    [mDetailViewController.view removeFromSuperview];
}

#pragma mark - Rotataion

//---------------------------------------------------------------
// Rotation
//---------------------------------------------------------------

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    MKViewMetrics toMetrics = MKMetricsOrientationMetrics(toInterfaceOrientation);
    
    [self viewsForMetrics:toMetrics inital:NO];
    
    if (toMetrics == MKMetricsLandscape) {
        [mListViewController viewWillAppear:YES];
        [mListViewController performSelector:@selector(viewDidAppear:) withObject:nil afterDelay:duration];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MKPopOutViewShouldRemoveNotification object:nil];
}

#pragma mark - Accessor Methods

//---------------------------------------------------------------
// Accessor Methods
//---------------------------------------------------------------

#pragma mark Getters

- (UIViewController *)detailViewController {
    return mDetailViewController;
}

- (UIViewController *)listViewController {
    return mListViewController;
}

- (BOOL)listViewIsVisable {
    return mListViewIsVisable;
}

#pragma mark - Subview Controller

//---------------------------------------------------------------
// Subview layouts
//---------------------------------------------------------------

- (void)viewsForMetrics:(MKViewMetrics)metrics inital:(BOOL)inital {
    mDetailViewController.view.frame = CGRectZero;
    
    BOOL tabBar = NO;
    
    if (self.tabBarController) {
        tabBar = YES;
    }

    if (metrics == MKMetricsLandscape) {
        mListViewController.view.frame = rectForListView(MKMetricsLandscape, tabBar);
        
        if (inital) {
            [self.view addSubview:mListViewController.view];
            [self.view addSubview:mDetailViewController.view];
        
            [(MKSplitView *)self.view addDetailNavigationBar];
            [(MKSplitView *)self.view addListNavigationBar];
        }
        else {
            [(MKSplitView *)self.view addListNavigationBar];
            [self.view addSubview:mListViewController.view];
            [self.detailViewController.navigationItem setLeftBarButtonItems:nil];
        }
        
        MKDividerView *divider = (MKDividerView *)[self.view viewWithTag:kMKDividerViewTag];
        
        if (divider) {
            [divider removeFromSuperview];
        }
        
        float x = (320.0 - 8.0);
        float y = 0.0;
        float width = 12.0;
        float height = MKMetricsHeightForMetrics(metrics);
        
        MKDividerView *shadowView = [[MKDividerView alloc] initWithFrame:CGRectMake(x, y, width, height) type:MKDividerViewSplit];
        shadowView.tag = kMKDividerViewTag;
        [self.view addSubview:shadowView];
        [self.view bringSubviewToFront:shadowView];
        [shadowView release];
        
        if (self.navigationController) {
            UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backButton:)];
            self.listViewController.navigationItem.leftBarButtonItem = back;
            [back release];
        }
    }
    else {
        mDetailViewController.view.frame = CGRectZero;
        
        if (inital) {
            [self.view addSubview:mDetailViewController.view];
            [(MKSplitView *)self.view addDetailNavigationBar];
        }
        else {
            MKDividerView *divider = (MKDividerView *)[self.view viewWithTag:kMKDividerViewTag];
            UINavigationBar *listBar = (UINavigationBar *)[self.view viewWithTag:kMKListViewNavigationBarTag];
            
            [divider removeFromSuperview];
            [listBar removeFromSuperview];
            [self.listViewController.view removeFromSuperview];
        }
        
        UIBarButtonItem *list = [[UIBarButtonItem alloc] initWithTitle:self.listViewController.title style:UIBarButtonItemStyleBordered target:self action:@selector(listButton:)];
        
        if (self.navigationController) {
            UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backButton:)];
            [self.detailViewController.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:back, list, nil] animated:NO];
            [back release];
        }
        else {
            [self.detailViewController.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:list, nil] animated:NO];
        }
        
        [list release];
        
        mListViewIsVisable = NO;
    }
    
    [self.view layoutForMetrics:metrics];
}

#pragma mark - Actions

//---------------------------------------------------------------
// Actons
//---------------------------------------------------------------

- (void)backButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)listButton:(id)sender {
    if (self.listViewIsVisable) {
        [self dismissListController];
    }
    else {
        [self presentListController];
    }
}

#pragma mark - Display Control

//---------------------------------------------------------------
// Display Contols
//---------------------------------------------------------------

- (void)presentListController {
    BOOL tabBar = NO;
    
    if (self.tabBarController) {
        tabBar = YES;
    }
    
    mListViewController.view.frame = startRectForListTransition(MKMetricsPortrait, tabBar);
    [self.view addSubview:mListViewController.view];
    
    [UIView animateWithDuration:0.25
                     animations:^ {
                         mListViewController.view.frame = rectForListView(MKMetricsPortrait, tabBar);
                     }
                     completion:^ (BOOL finished) {
                         mListViewIsVisable = YES;
                         
                         [self addListShaddow];
                     }];

}

- (void)dismissListController {
    if (MKMetricsCurrentOrientationMetrics() == MKMetricsPortrait) {
        BOOL tabBar = NO;
        
        if (self.tabBarController) {
            tabBar = YES;
        }
        
        MKDividerView *divider = (MKDividerView *)[self.view viewWithTag:kMKDividerViewTag];
        [divider removeFromSuperview];
        
        [UIView animateWithDuration:0.25
                         animations:^ {
                             mListViewController.view.frame = startRectForListTransition(MKMetricsPortrait, tabBar);
                         }
                         completion:^ (BOOL finished) {
                             [mListViewController.view removeFromSuperview];
                             mListViewIsVisable = NO;
                         }];
        
    }
}

- (void)addListShaddow {
    float x = 320.0;
    float y = 44.0;
    float width = 12.0;
    float height = (MKMetricsHeightForMetrics(MKMetricsCurrentOrientationMetrics()) - 44.0);
    
    if (self.tabBarController) {
        height = (height - 49.0);
    }
    
    MKDividerView *shadowView = [[MKDividerView alloc] initWithFrame:CGRectMake(x, y, width, height) type:MKDividerViewOverlap];
    shadowView.tag = kMKDividerViewTag;
    [self.view addSubview:shadowView];
    [self.view bringSubviewToFront:shadowView];
    [shadowView release];
}

@end

#pragma mark -

//---------------------------------------------------------------
// Split View Implementation
//---------------------------------------------------------------

@implementation MKSplitView

#pragma mark - Creation

//---------------------------------------------------------------
// Creation
//---------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    }
    return self;
}

#pragma mark - Layout

//---------------------------------------------------------------
// Layout
//---------------------------------------------------------------

- (void)layoutForMetrics:(MKViewMetrics)metrics {
    self.width = MKMetricsWidthForMetrics(metrics);
    
    MKMetrics *viewMetrics = [MKMetrics metricsForView:self];
    
    UIViewController *detailViewController = [(MKSplitViewController *)self.controller detailViewController];
    UINavigationBar *detailNavBar = (UINavigationBar *)[self viewWithTag:kMKDetailViewNavigaionBarTag];
    UIViewController *listViewController = [(MKSplitViewController *)self.controller listViewController];
    UINavigationBar *listNavBar = (UINavigationBar *)[self viewWithTag:kMKListViewNavigationBarTag];
    
    BOOL tabBar = NO;
    
    if (self.controller.tabBarController) {
        tabBar = YES;
    }
    
    [viewMetrics beginLayout];
    
    if (metrics == MKMetricsLandscape) {
        [listViewController.view setRect:rectForListView(metrics, tabBar) forMetrics:MKMetricsLandscape];
        [listNavBar setRect:rectForListNavigationBar() forMetrics:MKMetricsLandscape];
        
        [detailViewController.view setRect:rectForDetailView(metrics, tabBar) forMetrics:MKMetricsLandscape];
        [detailNavBar setRect:rectForDetailNavigationBar(metrics) forMetrics:MKMetricsLandscape];
        
        [viewMetrics layoutSubview:listViewController.view forMetrics:metrics];
        [viewMetrics layoutSubview:listNavBar forMetrics:metrics];
    }
    else {
        [detailViewController.view setRect:rectForDetailView(metrics, tabBar) forMetrics:MKMetricsPortrait];
        [detailNavBar setRect:rectForDetailNavigationBar(metrics) forMetrics:MKMetricsPortrait];
    }
    
    [viewMetrics layoutSubview:detailNavBar forMetrics:metrics];
    [viewMetrics layoutSubview:detailViewController.view forMetrics:metrics];
    [viewMetrics endLayout];
}

#pragma mark - Navigation Bars

//---------------------------------------------------------------
// Navigation Bars
//---------------------------------------------------------------

- (void)addDetailNavigationBar {
    UINavigationBar *detailNavBar = [[UINavigationBar alloc] initWithFrame:rectForDetailNavigationBar(MKMetricsCurrentOrientationMetrics())];
    detailNavBar.tag = kMKDetailViewNavigaionBarTag;
    
    [self addSubview:detailNavBar];
    
    MKSplitViewController *controller = (MKSplitViewController *)self.controller;
    NSArray *items = [NSArray arrayWithObject:controller.detailViewController.navigationItem];
    
    [detailNavBar setItems:items animated:NO];
    [detailNavBar release];
}

- (void)addListNavigationBar {
    UINavigationBar *listNavBar = [[UINavigationBar alloc] initWithFrame:rectForListNavigationBar()];
    listNavBar.tag = kMKListViewNavigationBarTag;
    
    [self addSubview:listNavBar];
    
    MKSplitViewController *controller = (MKSplitViewController *)self.controller;
    NSArray *items = [NSArray arrayWithObject:controller.listViewController.navigationItem];
    
    [listNavBar setItems:items animated:YES];
    [listNavBar release];
}

@end

#pragma mark -

//---------------------------------------------------------------
// Functions
//---------------------------------------------------------------

void drawSplitShadow(CGContextRef context, CGRect rect);
void drawOverlapShadow(CGContextRef context, CGRect rect);

//---------------------------------------------------------------
// Implementation
//---------------------------------------------------------------

@implementation MKDividerView

#pragma mark - Creation

//---------------------------------------------------------------
// Creation
//---------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame type:(MKDividerViewType)_type {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = CLEAR;
        type = _type;
    }
    return self;
}

#pragma mark - Drawing

//---------------------------------------------------------------
// Drawing
//---------------------------------------------------------------

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    
    if (type == MKDividerViewSplit) {
        drawSplitShadow(context, rect);
    }
    else if (type == MKDividerViewOverlap) {
        drawOverlapShadow(context, rect);
    }
}

#pragma mark Helpers

void drawSplitShadow(CGContextRef context, CGRect rect) {
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(-1.0, 0.0), 3.0, MK_SHADOW_COLOR);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, BLACK.CGColor);
    CGContextMoveToPoint(context, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(1.0, 0.0), 3.0, MK_SHADOW_COLOR);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, BLACK.CGColor);
    CGContextMoveToPoint(context, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

void drawOverlapShadow(CGContextRef context, CGRect rect) {
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(1.0, 0.0), 3.0, MK_SHADOW_COLOR);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, BLACK.CGColor);
    CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

@end
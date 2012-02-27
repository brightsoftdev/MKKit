//
//  MKIAPViewController.m
//  MKKit
//
//  Created by Matthew King on 5/29/11.
//  Copyright 2010-2011 Matt King. All rights reserved.
//

#import "MKIAPViewController.h"

#import <MKKit/MKKit/NSString+MKKit.h>

@interface MKIAPViewController ()

- (void)onProductsResponse:(NSArray *)items;

@end

@implementation MKIAPViewController

@synthesize items=mItems, observer=mObserver;

- (id)initWithIdentifiers:(NSSet *)identifiers observer:(id<MKIAPObserver>)observer {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        mIdentifiers = [identifiers copy];
        mObserver = observer;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Store";
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MKIAPController openStore];
    
    [MKIAPController productsRequestWithIdentifiers:mIdentifiers 
                                           response: ^ (SKProductsResponse *response, NSError *error) { 
                                               if (error == nil) {
                                                   [self onProductsResponse:response.products];
                                               }
                                               else {
                                                   MKErrorHandeling *handel = [[MKErrorHandeling alloc] init];
                                                   [handel applicationDidError:error];
                                                   [handel release];
                                               }
                                           }];
    
    [mIdentifiers release];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [MKIAPController closeStore];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:MK_REMOVE_BLOCK_OBJECT_NOTIFICATION object:nil];
    
    [self.view removeFromSuperview];
    self.view = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (void)onProductsResponse:(NSArray *)items {
    mItems = [items retain];
    mProductsSet = YES;
    [self.tableView reloadData];
    
    if ([mObserver respondsToSelector:@selector(didCompleteEvent:forIdentifiers:)]) {
        NSMutableSet *identifiers = [[NSMutableSet alloc] initWithCapacity:[items count]];
        for (SKProduct *product in items) {
            [identifiers addObject:product.productIdentifier];
        }
        [mObserver didCompleteEvent:MKIAPEventRequestComplete forIdentifiers:identifiers];
        [identifiers release];
    }
}

- (void)didRecieveResponse:(SKProductsResponse *)response {
    //mItems = [response.products retain];
    //mProductsSet = YES;
    //[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 1;
    
    if (mProductsSet) {
        rows = [mItems count];
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKTableCell *cell = nil;
    
    static NSString *LoadingCell = @"LoadingCell";
    static NSString *PurchaseCell = @"PurchaseCell";
    
    if (!mProductsSet) {
        cell = (MKTableCell *)[tableView dequeueReusableCellWithIdentifier:LoadingCell];
        if (cell == nil) {
            cell = [[[MKTableCellLoading alloc] initWithType:MKTableCellTypeNone reuseIdentifier:LoadingCell] autorelease];
        }
    }
    
    if (mProductsSet) {
        SKProduct *product = (SKProduct *)[mItems objectAtIndex:indexPath.row];
        NSString *string = [[NSString alloc] init];
        
        cell = (MKTableCell *)[tableView dequeueReusableCellWithIdentifier:PurchaseCell];
        if (cell == nil) {
            cell = [[[MKTableCellIAP alloc] initWithType:MKTableCellTypeNone reuseIdentifier:PurchaseCell] autorelease];
            cell.delegate = self;
            ((MKTableCellIAP *)cell).observer = mObserver;
        }
        cell.theLabel.text = product.localizedTitle;
        cell.key = product.productIdentifier;
        cell.indexPath = indexPath;
        ((MKTableCellIAP *)cell).IAPIdentifier = product.productIdentifier;
        ((MKTableCellIAP *)cell).price = [string localCurrencyFromNumber:product.price];
        
        [string release];
    }
    
    return cell;
}

#pragma mark - Delegates
#pragma mark UITableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - MKTableCell

- (void)didTapAccessoryForKey:(NSString *)aKey indexPath:(NSIndexPath *)indexPath {
    for (SKProduct *product in mItems) {
        if ([product.productIdentifier isEqualToString:aKey]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:product.localizedTitle message:product.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
    }
}

#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [mItems release];
    [super dealloc];
}

@end
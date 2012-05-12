//
//  MKDTableCellls.m
//  MKKitDemo
//
//  Created by Matthew King on 1/29/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKDTableCellls.h"
#import "MKDTextEntryCells.h"
#import "MKDControlCells.h"
#import "MKDCellAccessories.h"

@implementation MKDTableCellls

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ActionCell = @"ActionCell";
    
    MKTableCell *cell = (MKTableCell *)[tableView dequeueReusableCellWithIdentifier:ActionCell];
    
    if (cell == nil) {
        cell = [[[MKTableCell alloc] initWithType:MKTableCellTypeLabel reuseIdentifier:ActionCell] autorelease];
    }
    
    if (indexPath.row == 0) {
        cell.theLabel.text = @"Text Entry Cells";
        cell.image = [MKImage imageNamed:@"PenIconMask.png" graphicStruct:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row == 1) {
        cell.theLabel.text = @"Control Cells";
        cell.image = [MKImage imageNamed:@"ControlIcon.png" graphicStruct:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row == 2) {
        cell.theLabel.text = @"Cell Accessories";
        cell.image = [MKImage imageNamed:@"AccessoriesIcon.png" graphicStruct:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
    }   
    
    
    
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        MKDTextEntryCells *viewController = [[MKDTextEntryCells alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
    }
    if (indexPath.row == 1) {
        MKDControlCells *viewController = [[MKDControlCells alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
    }
    if (indexPath.row == 2) {
        MKDCellAccessories *viewController = [[MKDCellAccessories alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
    }
}

@end

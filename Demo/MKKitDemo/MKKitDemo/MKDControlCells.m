//
//  MKDControlCells.m
//  MKKitDemo
//
//  Created by Matt King on 5/11/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKDControlCells.h"

@interface MKDControlCells ()

@end

@implementation MKDControlCells

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKTableCell *cell = nil;
    
    static NSString *CheckBoxCell = @"CheckBoxCell";
    static NSString *SwitchCell = @"SwitchCell";
    static NSString *SliderCell = @"SliderCell";
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = (MKTableCellCheckBox *)[tableView dequeueReusableCellWithIdentifier:CheckBoxCell];
            if (cell == nil) {
                cell = [[[MKTableCellCheckBox alloc] initWithType:MKTableCellTypeNone reuseIdentifier:CheckBoxCell] autorelease];
            }
            
            cell.theLabel.text = @"Check Box";
        }
        if (indexPath.row == 1) {
            cell = (MKTableCellSwitch *)[tableView dequeueReusableCellWithIdentifier:SwitchCell];
            if (cell == nil) {
                cell = [[[MKTableCellSwitch alloc] initWithType:MKTableCellTypeNone reuseIdentifier:SwitchCell] autorelease];
            }
            
            cell.theLabel.text = @"Switch";
        }
        if (indexPath.row == 2) {
            cell = (MKTableCellSlider *)[tableView dequeueReusableCellWithIdentifier:SliderCell];
            if (cell == nil) {
                cell = [[[MKTableCellSlider alloc] initWithType:MKTableCellTypeNone reuseIdentifier:SliderCell] autorelease];
            }
        }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end

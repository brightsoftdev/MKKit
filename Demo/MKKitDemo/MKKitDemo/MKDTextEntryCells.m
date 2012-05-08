//
//  MKDTextEntryCells.m
//  MKKitDemo
//
//  Created by Matthew King on 2/25/12.
//  Copyright (c) 2012 Matt King. All rights reserved.
//

#import "MKDTextEntryCells.h"


@implementation MKDTextEntryCells

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    switch (section) {
        case 0: rows = 2; break;
        case 1: rows = 1; break;
        default: break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKTableCell *cell = nil;
    
    static NSString *TextFieldCell = @"TextCell";
    static NSString *TextViewCell = @"TextViewCell";
    
    if (indexPath.section == 0) {
        cell = (MKTableCell *)[tableView dequeueReusableCellWithIdentifier:TextFieldCell];
        if (indexPath.row == 0) {
            if (cell == nil) {
                cell = [[[MKTableCellTextEntry alloc] initWithType:MKTextEntryCellTypeStandard reuseIdentifier:TextFieldCell] autorelease];
            }
            
            cell.theLabel.text = @"Standard";
            ((MKTableCellTextEntry *)cell).theTextField.placeholder =@"Typing...";
            
        }
        if (indexPath.row == 1) {
            if (cell == nil) {
                cell = [[[MKTableCellTextEntry alloc] initWithType:MKTextEntryCellTypeFull reuseIdentifier:TextFieldCell] autorelease];
            }
            
            cell.image = [MKImage imageNamed:@"PenIconMask.png" graphicStruct:nil];
            ((MKTableCellTextEntry *)cell).theTextField.placeholder =@"Typing...";
        }
    }
    
    if (indexPath.section == 1) {
        cell = (MKTableCell *)[tableView dequeueReusableCellWithIdentifier:TextViewCell];
        if (cell == nil) {
            cell = [[[MKTableCellTextView alloc] initWithType:MKTableCellTypeNone reuseIdentifier:TextViewCell] autorelease];
        }
        
        ((MKTableCellTextView *)cell).theTextView.text = @"Tap to type";
    }
        
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44.0;
    if (indexPath.section == 1) {
        height = 73.0;
    }
    
    return height;
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

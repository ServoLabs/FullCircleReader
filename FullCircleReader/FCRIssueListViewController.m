//
//  FCRIssueListViewController.m
//  FullCircleReader
//
//  Created by Bryce Penberthy on 2/8/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//

#import "FCRIssueListViewController.h"
#import <NewsstandKit/NewsstandKit.h>
#import "IssueCellView.h"

@implementation FCRIssueListViewController

@synthesize issues = _issues;

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
    self.issues = [[NKLibrary sharedLibrary] issues];
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
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.issues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"IssueCell";
    
    IssueCellView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
       NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"IssueCellView"
                                                                 owner:self options:nil];
        for(id currentObject in topLevelObjects)  {
            if ([currentObject isKindOfClass:[UITableViewCell class]])  {
                cell = (IssueCellView*) currentObject;
            }
        }
    }
    
    NKIssue *issue = [self.issues objectAtIndex:indexPath.row];
    NSURL *issueDataPath = [issue.contentURL URLByAppendingPathComponent:@"issueData.plist"];
    NSDictionary *issueData = [NSDictionary dictionaryWithContentsOfURL:issueDataPath];
    NSURL *coverArtPath = [issue.contentURL URLByAppendingPathComponent:@"CoverImage.png"];
    UIImage *coverImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:coverArtPath]];
    
    cell.nameLabel.text = issue.name;
    cell.subTitleLabel.text = [issueData valueForKey:@"SubTitle"];
    cell.publicationDateLabel.text = @"Not showing dates yet.";
    cell.coverImage.image = coverImage;
    cell.spinner.hidden = YES;
    cell.progressView.hidden = YES;
    if ([[issueData valueForKey:@"ContentWasDownloaded"] boolValue])  {
        cell.downloadButton.hidden = YES;
        cell.subTitleLabel.hidden = NO;
    } else  {
        cell.downloadButton.hidden = NO;        
        if ([issue.downloadingAssets count] != 0)  {
            //cell.spinner.hidden = NO;
            //[cell.spinner startAnimating];
            cell.progressView.hidden = NO;
            cell.subTitleLabel.hidden = YES;
            
            float downloadProgress = [[issueData valueForKey:@"DownloadProgress"] floatValue];
            NSLog(@"Issue: %@  -- Download Progress: %f", issue.name, downloadProgress);
            cell.progressView.progress = [[issueData valueForKey:@"DownloadProgress"] floatValue];
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
     */
}

@end

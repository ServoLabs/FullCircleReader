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
#import "FCRIssueProcessor.h"

@implementation FCRIssueListViewController

@synthesize headerView = _headerView;
@synthesize spinner = _spinner;
@synthesize displayIssue = _displayIssue;
@synthesize downloadIssue = _downloadIssue;


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
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  {
    
	if (0 == section)  {
		return self.headerView;
	} 

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (0 == section)  {
        return self.headerView.frame.size.height;
    }
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[NKLibrary sharedLibrary ].issues count];
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
    
    NKIssue *issue = [[NKLibrary sharedLibrary].issues objectAtIndex:indexPath.row];
    NSURL *issueDataPath = [issue.contentURL URLByAppendingPathComponent:@"issueData.plist"];
    NSDictionary *issueData = [NSDictionary dictionaryWithContentsOfURL:issueDataPath];
    NSURL *coverArtPath = [issue.contentURL URLByAppendingPathComponent:@"CoverImage.png"];
    UIImage *coverImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:coverArtPath]];
    
    cell.nameLabel.text = issue.name;
    cell.subTitleLabel.text = [issueData valueForKey:@"subTitle"];
    cell.coverImage.image = coverImage;
    cell.spinner.hidden = YES;
    cell.progressView.hidden = YES;
 
    // Set the publication date label
    NSDate *today = [issueData valueForKey:@"pubDate"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM, YYYY"];
    NSString *dateString = [dateFormat stringFromDate:today];
    cell.publicationDateLabel.text = dateString;
    
    if ([[issueData valueForKey:@"contentWasDownloaded"] boolValue])  {
        cell.downloadButton.hidden = YES;
        cell.subTitleLabel.hidden = NO;
    } else  {
        cell.downloadButton.hidden = NO;        
        if ([issue.downloadingAssets count] != 0)  {
            cell.progressView.hidden = NO;
            cell.subTitleLabel.hidden = YES;
            cell.downloadButton.hidden = YES;
            
            float downloadProgress = [[issueData valueForKey:@"downloadProgress"] floatValue];
            NSLog(@"Issue: %@  -- Download Progress: %f", issue.name, downloadProgress);
            cell.progressView.progress = downloadProgress;
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
    NKIssue *issue = [[NKLibrary sharedLibrary].issues objectAtIndex:indexPath.row];
    NSURL *issueDataPath = [issue.contentURL URLByAppendingPathComponent:@"issueData.plist"];
    NSDictionary *issueData = [NSDictionary dictionaryWithContentsOfURL:issueDataPath];
    
    // If the issue has been downloaded, then open it up in the reader.
    if ([[issueData valueForKey:@"contentWasDownloaded"] boolValue])  {
       
        [self displayIssue](issue);        

    } else  {
        // If the issue hasn't been downloaded, then selecting a row will make a request
        // to start downloading this issue.
        if ([issue.downloadingAssets count] == 0)  {
            [self downloadIssue](issue);
        }
    }
    
    // If the issue is currently downloading then do nothing.
}

@end

//
//  FCRRootViewController.m
//  FullCircleReader
//
//  Created by Bryce Penberthy on 1/19/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//

#import "FCRRootViewController.h"

#import "FCRModelController.h"

#import "FCRDataViewController.h"
#import "SBJson.h"

@interface FCRRootViewController ()
@property (readonly, strong, nonatomic) FCRModelController *modelController;
@property (nonatomic) BOOL popoverVisible;

- (void) initalizeIssueList;
- (void) writeDownloadProgressToFile:(NSURLConnection *)connection withProgress:(float)progress;
- (void) openIssue:(NKIssue *)issue;

- (void) registerForRemotePushNotifications;  

@end

@implementation FCRRootViewController

@synthesize pageViewController = _pageViewController;
@synthesize modelController = _modelController;
@synthesize issueListButton = _issueListButton;
@synthesize issueListViewController = _issueListViewController;
@synthesize trayListPopover = _trayListPopover;
@synthesize popoverVisible;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;

    FCRDataViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:self.storyboard];
    NSArray *viewControllers = [NSArray arrayWithObject:startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];

    self.pageViewController.dataSource = self.modelController;

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        pageViewRect = CGRectInset(pageViewRect, 50.0, 40.0);
    }
    self.pageViewController.view.frame = pageViewRect;

    [self.pageViewController didMoveToParentViewController:self];    

    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    
    self.issueListViewController = [[FCRIssueListViewController alloc] initWithNibName:@"FCRIssueListViewController" bundle:[NSBundle mainBundle]];
    
    __block __typeof__(self) blockSelf = self;
    self.issueListViewController.downloadIssue = ^(NKIssue* issue) {
        [blockSelf startDownloadingIssue:issue];
    };
    
    self.issueListViewController.displayIssue = ^(NKIssue *issue) {
        [blockSelf openIssue:issue];
    };
    
    popoverVisible = NO;
    
    if ([[[NKLibrary sharedLibrary ] issues] count] == 0)  {
        [self initalizeIssueList];
    }
}

- (void) initalizeIssueList  {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"IssueCatalog" ofType:@"plist"];
    NSDictionary *issueCatalogDict = [[NSDictionary alloc] initWithContentsOfFile:path];

    NSArray *backIssues = [issueCatalogDict valueForKey:@"BackIssues"];
    NKLibrary *myLibrary = [NKLibrary sharedLibrary];
    NKIssue *latestIssue = nil;
    NSDictionary *latestIssueMetaData = nil;
    for(NSDictionary *issueData in backIssues)  {
        NSMutableDictionary *savedIssueData = [NSMutableDictionary dictionaryWithDictionary:issueData];
        NSDate *pubDate = [savedIssueData valueForKey:@"PubDate"];
        NKIssue *issue = [myLibrary addIssueWithName:[savedIssueData valueForKey:@"Name"] date:pubDate];
        
        NSURL *coverImageUrl = [NSURL URLWithString:[savedIssueData valueForKey:@"CoverImageUrl"]];
        UIImage *coverImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:coverImageUrl]];
        
        NSURL *savedCoverImagePath = [issue.contentURL URLByAppendingPathComponent:@"CoverImage.png"];
        [UIImagePNGRepresentation(coverImage) writeToURL:savedCoverImagePath atomically:YES];
        
        [savedIssueData setValue:[NSNumber numberWithBool:NO] forKey:@"ContentWasDownloaded"];

        NSURL *metaDataPath = [issue.contentURL URLByAppendingPathComponent:@"issueData.plist"];
        [savedIssueData writeToURL:metaDataPath atomically:YES];

        if (latestIssue == nil)  {
            latestIssue = issue;
            latestIssueMetaData = savedIssueData;
        } else if ([latestIssue.date laterDate:issue.date] == issue.date)  {
            latestIssue = issue;
            latestIssueMetaData = savedIssueData;
        }
    }
    
    [myLibrary setCurrentlyReadingIssue:latestIssue];
    
    [self startDownloadingIssue:latestIssue];

}

- (void) startDownloadingIssue:(NKIssue *)issue  {
    NSURL *issueDataPath = [issue.contentURL URLByAppendingPathComponent:@"issueData.plist"];
    NSDictionary *issueData = [NSDictionary dictionaryWithContentsOfURL:issueDataPath];

    NSString *contentUrl = [issueData valueForKey:@"ContentUrl"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:contentUrl]];
    NKAssetDownload *asset = [issue addAssetWithRequest:request];
    [asset downloadWithDelegate:self]; 

}

- (void) openIssue:(NKIssue *)issue  {
    // Display the current issue in the main PDF viewer.
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || 
                (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
}

- (FCRModelController *)modelController
{
    /*
     Return the model controller object, creating it if necessary.
     In more complex implementations, the model controller may be passed to the view controller.
     */
    if (!_modelController) {
        _modelController = [[FCRModelController alloc] init];
    }
    return _modelController;
}

#pragma mark - UIPageViewController delegate methods

/*
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    
}
 */

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation) || ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) {
        // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
        
        UIViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
        NSArray *viewControllers = [NSArray arrayWithObject:currentViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
        
        self.pageViewController.doubleSided = NO;
        return UIPageViewControllerSpineLocationMin;
    }

    // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
    FCRDataViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
    NSArray *viewControllers = nil;

    NSUInteger indexOfCurrentViewController = [self.modelController indexOfViewController:currentViewController];
    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
        UIViewController *nextViewController = [self.modelController pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
        viewControllers = [NSArray arrayWithObjects:currentViewController, nextViewController, nil];
    } else {
        UIViewController *previousViewController = [self.modelController pageViewController:self.pageViewController viewControllerBeforeViewController:currentViewController];
        viewControllers = [NSArray arrayWithObjects:previousViewController, currentViewController, nil];
    }
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];


    return UIPageViewControllerSpineLocationMin;
}

-(IBAction) issueListButtonPushed:(id) sender  {
    if (!popoverVisible)  {
        self.trayListPopover = [[UIPopoverController alloc] initWithContentViewController:self.issueListViewController];
        self.trayListPopover.delegate = self;
        
        [self.trayListPopover presentPopoverFromBarButtonItem:self.issueListButton 
                                     permittedArrowDirections:UIPopoverArrowDirectionAny 
                                                     animated:YES];
        self.popoverVisible = YES;
    } else  {
        [self.trayListPopover dismissPopoverAnimated:YES];
        self.popoverVisible = NO;
    }
}

#pragma mark - NSURLConnectionDownloadDelegate  

-(void) connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL  {
    NKAssetDownload *asset = connection.newsstandAssetDownload;
    NKIssue *issue = asset.issue;
    
    NSURL *issueContentPath = [issue.contentURL URLByAppendingPathComponent:@"IssueContent.pdf"];
    [[NSFileManager defaultManager] copyItemAtURL:destinationURL toURL:issueContentPath error:nil];
    
    // We need some error handling here just in case we couldn't copy the issue content.
    
    NSURL *issueDataPath = [issue.contentURL URLByAppendingPathComponent:@"issueData.plist"];
    NSMutableDictionary *issueData = [NSMutableDictionary dictionaryWithContentsOfURL:issueDataPath];
    
    [issueData setValue:[NSNumber numberWithBool:YES] forKey:@"ContentWasDownloaded"];
    
    [issueData writeToURL:issueDataPath atomically:YES];

    [self.issueListViewController.tableView reloadData];
}

-(void) connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes  {
    [self writeDownloadProgressToFile:connection withProgress:((float)totalBytesWritten / (float)expectedTotalBytes)];
    [self.issueListViewController.tableView reloadData];
}

-(void) connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes  {

    [self writeDownloadProgressToFile:connection withProgress:((float)totalBytesWritten / (float)expectedTotalBytes)];
    [self.issueListViewController.tableView reloadData];    
}

-(void) writeDownloadProgressToFile:(NSURLConnection *)connection withProgress:(float)progress  {
    NKAssetDownload *asset = connection.newsstandAssetDownload;
    NKIssue *issue = asset.issue;
    
    NSURL *issueDataPath = [issue.contentURL URLByAppendingPathComponent:@"issueData.plist"];
    NSMutableDictionary *issueData = [NSMutableDictionary dictionaryWithContentsOfURL:issueDataPath];
    
    [issueData setValue:[NSNumber numberWithFloat:progress] forKey:@"DownloadProgress"];
    
    [issueData writeToURL:issueDataPath atomically:YES];
    NSLog(@"Writing progress of %f to the dictionary.", progress);

}
@end

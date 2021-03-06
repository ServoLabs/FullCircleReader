//
//  FCRRootViewController.m
//  FullCircleReader
//
//  Created by Bryce Penberthy on 1/19/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//

#import "FCRRootViewController.h"
#import "PDFPageView.h"
#import "FCRModelController.h"
#import "FCRDataViewController.h"
#import <UIKit/UIKit.h>
#import "FCRIssueProcessor.h"
#import "FCRAppDelegate.h"

#define BORDER_WIDTH 15

@interface FCRRootViewController ()
@property (readonly, strong, nonatomic) FCRModelController *modelController;

- (void) setupPageViewController;
- (void) initalizeIssueList;
- (void) initializeModelController:(NKIssue *) issue;
@end

@implementation FCRRootViewController;

@synthesize pageViewController = _pageViewController;
@synthesize modelController = _modelController;
@synthesize issueListButton = _issueListButton;
@synthesize issueListViewController = _issueListViewController;
@synthesize trayListPopover = _trayListPopover;
@synthesize pdfDocument = _pdfDocument;

NSString * const IssueContentPDF = @"IssueContent.pdf";
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.pageViewController.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
        
    [self setupPageViewController];
    
    FCRAppDelegate *appDelegate = (FCRAppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.issueProcessor.downloadDelegate = self;
    
    self.issueListViewController = [[FCRIssueListViewController alloc] initWithNibName:@"FCRIssueListViewController" bundle:[NSBundle mainBundle]];
    
    __block __typeof__(self) blockSelf = self;
    self.issueListViewController.downloadIssue = ^(NKIssue* issue) {
        [appDelegate.issueProcessor startDownloadingIssue:issue];
    };
    
    self.issueListViewController.displayIssue = ^(NKIssue *issue) {
        [blockSelf openIssue:issue];
    };
    
    self.issueListViewController.deleteIssue = ^(NKIssue* issue){
        [blockSelf deleteIssue: issue];
    };
    
    appDelegate.updateStatusDelegate = self;
    
}

- (void) initalizeIssueList  {
    FCRAppDelegate *appDelegate = (FCRAppDelegate*) [[UIApplication sharedApplication] delegate];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"IssueCatalog" ofType:@"plist"];
    NSDictionary *issueCatalogDict = [[NSDictionary alloc] initWithContentsOfFile:path];

    NSArray *backIssues = [issueCatalogDict valueForKey:@"BackIssues"];
    NKLibrary *myLibrary = [NKLibrary sharedLibrary];
    NKIssue *latestIssue = nil;
    for(NSDictionary *issueData in backIssues)  {
        NKIssue *issue = [appDelegate.issueProcessor processIssueForDictionary:issueData];

        if (latestIssue == nil)  {
            latestIssue = issue;
        } else if ([latestIssue.date laterDate:issue.date] == issue.date)  {
            latestIssue = issue;
        }
    }    
    [myLibrary setCurrentlyReadingIssue:latestIssue];    
    [appDelegate.issueProcessor startDownloadingLatestIssue];

}


- (void) openIssue:(NKIssue *)issue  {
    [[NKLibrary sharedLibrary] setCurrentlyReadingIssue:issue];
    [self setupPDFDocument:issue];
    [self initializeModelController:issue ];
    [self setupPageViewController];
}

-(void) setupPDFDocument :(NKIssue *)issue {
    if(self.pdfDocument != nil){
        CGPDFDocumentRelease(self.pdfDocument);
        self.pdfDocument = nil;
    }      
    NSURL *issueContentPath = [self getIssueContentPath: issue];
    NSData *data =[[NSData alloc] initWithContentsOfURL:issueContentPath];
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((__bridge_retained CFDataRef)data);
    self.pdfDocument = CGPDFDocumentCreateWithProvider(dataProvider);
}

- (NSURL*) getIssueContentPath:(NKIssue *)issue {
    NSURL *issueContentPath = [issue.contentURL URLByAppendingPathComponent:IssueContentPDF];
    return issueContentPath;
}

- (void) deleteIssue:(NKIssue *)issue  {
    NSError *error;
    NSURL *issueContentPath = [issue.contentURL  URLByAppendingPathComponent:IssueContentPDF];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager removeItemAtURL:issueContentPath error:&error] != YES){
       // NSLog(@"Unable to delete file: %@", [fileManager contentsOfDirectoryAtPath:issueContentPath error:&error]);
    }
}

- (void) setupPageViewController{
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
    
    FCRDataViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:self.storyboard];
    NSArray *viewControllers = [NSArray arrayWithObject:startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
    self.pageViewController.dataSource = self.modelController;
        
    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {         
        CGRect scoochedDownRectangle = CGRectMake(BORDER_WIDTH, 21 + BORDER_WIDTH, 
                                                  pageViewRect.size.width - (BORDER_WIDTH * 2), 
                                                  pageViewRect.size.height - (BORDER_WIDTH * 2));
        pageViewRect = CGRectInset(scoochedDownRectangle, 1, 20.0);
    }
    self.pageViewController.view.frame = pageViewRect;

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    
    //self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
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
    if (nil != [NKLibrary sharedLibrary].currentlyReadingIssue)  {
        [self openIssue:[NKLibrary sharedLibrary].currentlyReadingIssue];
    }
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

- (void)initializeModelController:(NKIssue *) issue
{
    _modelController = nil;   
    _modelController = [[FCRModelController alloc] initWithNKIssue:issue andPdfDocument: self.pdfDocument];
    
}

#pragma mark - UIPageViewController delegate methods


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    
}


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
    if (self.trayListPopover == nil)  {
        self.trayListPopover = [[UIPopoverController alloc] initWithContentViewController:self.issueListViewController];
        self.trayListPopover.delegate = self;
    }
    
    if  (!self.trayListPopover.isPopoverVisible) {
        [self.trayListPopover presentPopoverFromBarButtonItem:self.issueListButton
                                permittedArrowDirections:UIPopoverArrowDirectionAny
                                                     animated:YES];
    } else  {
        [self.trayListPopover dismissPopoverAnimated:YES];
    }
}

#pragma mark - NSURLConnectionDownloadDelegate  

-(void) connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL  {
    [self.issueListViewController.tableView reloadData];
}

-(void) connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes  {
    [self.issueListViewController.tableView reloadData];
}

-(void) connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes  {

    [self.issueListViewController.tableView reloadData];    
}

-(void) startedUpdating  {
    if (nil != self.issueListViewController)  {
        [self.issueListViewController.spinner startAnimating];
    }
}

-(void) finishedUpdating  {
    if (nil != self.issueListViewController)  {
        [self.issueListViewController.spinner stopAnimating];
        [self.issueListViewController.tableView reloadData];
    }
}


@end

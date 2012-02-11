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
#import <NewsstandKit/NewsstandKit.h>

@interface FCRRootViewController ()
@property (readonly, strong, nonatomic) FCRModelController *modelController;
@property (nonatomic) BOOL popoverVisible;

- (void) initalizeIssueList;
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
    popoverVisible = NO;
    
    if ([[[NKLibrary sharedLibrary ] issues] count] == 0)  {
//        [self initalizeIssueList];
    }
}

- (void) initalizeIssueList  {
    // Get the latest issue.
    NSString *latestIssueUrl = @"http://notifier.fullcirclemagazine.org/en/latest.json";

    NSLog(@"Retrieving latest issue info");
    NSData *latestIssueData = 
    [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:latestIssueUrl ]]
                          returningResponse:nil 
                                      error:nil];
    NSString *latestJson = [[NSString alloc] initWithData:latestIssueData encoding:NSUTF8StringEncoding] ;
    NSLog(@"Got: %@", latestJson);
    
    NSDictionary *latestIssueDict = [latestJson JSONValue];
    
    // Get the issue value # to build the other strings.
    NSNumber *latestIssueNumber = [latestIssueDict valueForKey:@"mag"]; 
    
    NKLibrary *myLibrary = [NKLibrary sharedLibrary];
    NSDate *issueDate = [NSDate date];
    
    for (NSInteger idx=[latestIssueNumber integerValue]; idx>=1; idx--)  {
        NSString *issueUrl = [NSString stringWithFormat:@"http://notifier.fullcirclemagazine.org/en/mag/%d.json", idx];
        NSLog(@"Trying to get issue info from %@", issueUrl);

        NSError *error = nil;
        NSData *issueData = 
        [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:issueUrl ]]
                              returningResponse:nil 
                                          error:&error];
        if (nil != error)  {
            NSLog(@"Got an error trying to retrieve data for issue %d: %@", idx, [error localizedDescription]);
        } else  {
            NSString *issueJson = [[NSString alloc] initWithData:issueData encoding:NSUTF8StringEncoding] ;
            NSLog(@"Got: %@", issueJson);
            
            NSDictionary *issueDict = [issueJson JSONValue];
            NSString *issueName = [issueDict valueForKey:@"title"];
            if ([issueName isEqual:[NSNull null]])  {
                issueName = [issueDict valueForKey:@"desc"];
            }
            if ([issueName isEqual:[NSNull null]])  {
                issueName = [NSString stringWithFormat:@"Issue #%d", idx + 1];
            }
            NKIssue *issue = [myLibrary addIssueWithName:issueName date:issueDate];
            
            if (idx == [latestIssueNumber integerValue])  {
                [myLibrary setCurrentlyReadingIssue:issue];
            }
            
        }
        
    }
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

@end

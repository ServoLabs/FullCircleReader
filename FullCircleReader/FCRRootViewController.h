//
//  FCRRootViewController.h
//  FullCircleReader
//
//  Created by Bryce Penberthy on 1/19/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NewsstandKit/NewsstandKit.h>
#import "FCRIssueListViewController.h"
#import "FCRUpdateStatusDelegate.h"

@interface FCRRootViewController : UIViewController <UIPageViewControllerDelegate, UIPopoverControllerDelegate,
                                                    NSURLConnectionDownloadDelegate, FCRUpdateStatusDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *issueListButton;
@property(nonatomic, strong) FCRIssueListViewController *issueListViewController;
@property(nonatomic, strong) UIPopoverController *trayListPopover;

-(IBAction) issueListButtonPushed:(id) sender;
<<<<<<< HEAD
-(void) openIssue:(NKIssue *)issue;
=======
-(void) openIssue:(NKIssue *)issue ;
>>>>>>> origin/master

@end

//
//  FCRRootViewController.h
//  FullCircleReader
//
//  Created by Bryce Penberthy on 1/19/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCRIssueListViewController.h"

@interface FCRRootViewController : UIViewController <UIPageViewControllerDelegate, UIPopoverControllerDelegate,
                                                    NSURLConnectionDownloadDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *issueListButton;
@property(nonatomic, strong) FCRIssueListViewController *issueListViewController;
@property(nonatomic, strong) UIPopoverController *trayListPopover;

-(IBAction) issueListButtonPushed:(id) sender;

@end

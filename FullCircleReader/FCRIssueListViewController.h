//
//  FCRIssueListViewController.h
//  FullCircleReader
//
//  Created by Bryce Penberthy on 2/8/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NewsstandKit/NewsstandKit.h>

@interface FCRIssueListViewController : UITableViewController

@property(nonatomic, strong) NSArray *issues;
@property (copy, nonatomic) void (^displayIssue) (NKIssue*) ;
@property (copy, nonatomic) void (^downloadIssue) (NKIssue*) ;

@end

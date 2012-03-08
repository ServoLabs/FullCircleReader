//
//  FCRModelController.h
//  FullCircleReader
//
//  Created by Bryce Penberthy on 1/19/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NewsstandKit/NewsstandKit.h>
@class FCRDataViewController;

@interface FCRModelController : NSObject <UIPageViewControllerDataSource>
- (FCRDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(FCRDataViewController *)viewController;
- (void) loadPDFPageView:(NSUInteger)index intoViewController:(FCRDataViewController *)dataViewController;
@property(nonatomic, strong) NKIssue *currentIssue;
@end

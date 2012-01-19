//
//  FCRModelController.h
//  FullCircleReader
//
//  Created by Bryce Penberthy on 1/19/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FCRDataViewController;

@interface FCRModelController : NSObject <UIPageViewControllerDataSource>
- (FCRDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(FCRDataViewController *)viewController;
@end

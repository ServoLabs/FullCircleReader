//
//  FCRModelController.h
//  FullCircleReader
//
//  Created by Bryce Penberthy on 1/19/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NewsstandKit/NewsstandKit.h>
#import "PDFPageView.h"

extern NSString * const IssueContentPDF;
@class FCRDataViewController;

@interface FCRModelController : NSObject <UIPageViewControllerDataSource>
- (FCRDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(FCRDataViewController *)viewController;
- (id)initWithNKIssue:(NKIssue *) issue;

@property(nonatomic) CGPDFDocumentRef pdfDocument;
@property(nonatomic, strong) PDFPageView *pageView;
@property(nonatomic, strong) NKIssue *currentIssue;
@end

//
//  FCRModelController.m
//  FullCircleReader
//
//  Created by Bryce Penberthy on 1/19/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "FCRModelController.h"

#import "FCRDataViewController.h"
#import "PDFPageView.h"
/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */

@interface FCRModelController()
@property (strong, nonatomic) NSMutableArray *pageData;
- (NSURL*) getIssueContentPath;
- (void) initializePDFPageNumbers;
- (void) initializePageData;
- (void) loadPDFPageView:(NSUInteger)index intoViewController:(FCRDataViewController *)dataViewController;
@end

@implementation FCRModelController

@synthesize pageData = _pageData;
@synthesize currentIssue = _currentIssue;
@synthesize pageView = _pageView;
@synthesize pdfDocument = _pdfDocument;

NSString * const IssueContentPDF = @"IssueContent.pdf";
NSString * const PageNumberFormat = @"Page - %d";
NSInteger numberOfPages;

CGPDFPageRef page;
- (id)init
{
    self = [super init];
    if (self) {
        // Create the data model.
        [self initializePageData];
    }
    return self;
}
- (id)initWithNKIssue:(NKIssue *) issue
{
    NSLog(@"InitModelController");
    self = [super init];
    if (self) {
        self.currentIssue = issue;    
        [self initializePageData]; 
        if(self.pdfDocument != nil){
            CGPDFDocumentRelease(self.pdfDocument);
        }
        [self setupPDFDocument];   
        numberOfPages = CGPDFDocumentGetNumberOfPages(self.pdfDocument);
        [self initializePDFPageNumbers];
           
    }
    return self;
}

-(void) setupPDFDocument{
    NSURL *issueContentPath = [self getIssueContentPath];
    NSData *data =[[NSData alloc] initWithContentsOfURL:issueContentPath];
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((__bridge_retained CFDataRef)data);
    self.pdfDocument = CGPDFDocumentCreateWithProvider(dataProvider);
}

- (FCRDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{   
    if (([self.pageData count] == 0) || (index >= [self.pageData count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    FCRDataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"FCRDataViewController"];    
    dataViewController.dataObject = [self.pageData objectAtIndex:index];    
    [self loadPDFPageView:index intoViewController:dataViewController];
    return dataViewController;
}


#pragma mark -PDFViewLoader

- (void) loadPDFPageView:(NSUInteger)index intoViewController:(FCRDataViewController *)dataViewController
{
    //NSLog(@"loadPDFPageView");
    NSInteger physicalPageNumber = index + 1;     
    page = CGPDFDocumentGetPage(self.pdfDocument, physicalPageNumber);
    CGPDFPageRetain(page);    
    self.pageView = [[PDFPageView alloc] init];
    self.pageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;    
    self.pageView.backgroundColor = [UIColor whiteColor];
    self.pageView.page = page;
    dataViewController.view = self.pageView;
    CGPDFPageRelease(page);
    
}

- (void) initializePDFPageNumbers{
    //NSLog(@"initializePDFPageNumbers");
    NSMutableArray* pageData = [NSMutableArray arrayWithCapacity: numberOfPages];    
    for (NSInteger pageIndex = 1; pageIndex <= numberOfPages; pageIndex++) {
        [pageData addObject: [NSString stringWithFormat:PageNumberFormat, pageIndex]];
    }
    self.pageData= pageData;
}

- (NSURL*) getIssueContentPath {
    NSURL *issueContentPath = [self.currentIssue.contentURL URLByAppendingPathComponent:IssueContentPDF];
    return issueContentPath;
}

- (void) initializePageData {
    
    if(self.currentIssue == nil) {
        self.pageData = [NSMutableArray arrayWithCapacity:1];
        [self.pageData addObject:[NSString stringWithFormat:PageNumberFormat, 1]];        
        return;
    }        
    [self initializePDFPageNumbers];
}

- (NSUInteger)indexOfViewController:(FCRDataViewController *)viewController
{   
    /*
     Return the index of the given data view controller.
     For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
     */
    return [self.pageData indexOfObject:viewController.dataObject];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(FCRDataViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(FCRDataViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }    
    index++;
    if (index == [self.pageData count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}


@end

//
//  IssueMetadataProcessor.h
//  FullCircleReader
//
//  Created by Bryce Penberthy on 3/20/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NewsstandKit/NewsstandKit.h>

@interface FCRIssueProcessor : NSObject<NSURLConnectionDownloadDelegate>

@property(nonatomic, weak) id<NSURLConnectionDownloadDelegate> downloadDelegate;

-(NKIssue*) processIssueForDictionary:(NSDictionary*) metaData;
-(NKIssue*) findIssueWithDate:(NSDate*) pubDate;
-(NSDateComponents*) buildDateComponentsFromDate:(NSDate *) dateValue;
-(NKIssue*) getLastIssueFromDevice;
-(void) startDownloadingIssue:(NKIssue *) issue;
-(void) startDownloadingLatestIssue;

@end

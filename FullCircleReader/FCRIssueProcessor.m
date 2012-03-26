//
//  IssueMetadataProcessor.m
//  FullCircleReader
//
//  Created by Bryce Penberthy on 3/20/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//

#import "FCRIssueProcessor.h"

@implementation FCRIssueProcessor

@synthesize downloadDelegate;

-(NKIssue*) processIssueForDictionary:(NSDictionary*) metaData  {
    
    NSMutableDictionary *savedIssueData = [NSMutableDictionary dictionaryWithDictionary:metaData];
    NSDate *pubDate = [savedIssueData valueForKey:@"pubDate"];
    NKIssue *issue = [self findIssueWithDate:pubDate];
    if (issue == nil)  {
        issue = [[NKLibrary sharedLibrary] addIssueWithName:[savedIssueData valueForKey:@"name"] date:pubDate];
        
        NSURL *coverImageUrl = [NSURL URLWithString:[savedIssueData valueForKey:@"coverArtUrl"]];
        UIImage *coverImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:coverImageUrl]];
        
        NSURL *savedCoverImagePath = [issue.contentURL URLByAppendingPathComponent:@"CoverImage.png"];
        [UIImagePNGRepresentation(coverImage) writeToURL:savedCoverImagePath atomically:YES];
        
        [savedIssueData setValue:[NSNumber numberWithBool:NO] forKey:@"contentWasDownloaded"];
        
        NSURL *metaDataPath = [issue.contentURL URLByAppendingPathComponent:@"issueData.plist"];
        [savedIssueData writeToURL:metaDataPath atomically:YES];
    }
    return issue;
}

-(NKIssue*) getLastIssueFromDevice  {
    NKIssue *latestIssue = nil;
    NSArray *issues = [[NKLibrary sharedLibrary] issues];
    for (NKIssue *issue in issues)  {
        if (latestIssue == nil)  {
            latestIssue = issue;
        } else  {
            if ([issue.date laterDate:latestIssue.date] == issue.date)  {
                latestIssue = issue;
            }
        }
    }
    return latestIssue;
}
    
-(NKIssue*) findIssueWithDate:(NSDate*) pubDate  {
    NSArray *issues = [[NKLibrary sharedLibrary] issues];
    
    // Only compare date, not time.
    NSDateComponents *comps = [self buildDateComponentsFromDate:pubDate];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    for(NKIssue *issue in issues)  {
        NSDateComponents *issueDateComps = [self buildDateComponentsFromDate:issue.date];
        if ([[calendar dateFromComponents:comps] isEqualToDate:[calendar dateFromComponents:issueDateComps]])  {
            return issue;
        }
    }
    return nil;
}

-(NSDateComponents*) buildDateComponentsFromDate:(NSDate *) dateValue  {
    NSCalendar *cal = [NSCalendar currentCalendar];
    return [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
                                     fromDate:dateValue];
    
}

-(void) startDownloadingIssue:(NKIssue *) issue  {
    if (nil != issue)  {
        NSURL *issueDataPath = [issue.contentURL URLByAppendingPathComponent:@"issueData.plist"];
        NSDictionary *issueData = [NSDictionary dictionaryWithContentsOfURL:issueDataPath];
        
        if (NO == [[issueData valueForKey:@"contentWasDownloaded"] boolValue])  {
            NSString *contentUrl = [issueData valueForKey:@"contentUrl"];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:contentUrl]];
            NKAssetDownload *asset = [issue addAssetWithRequest:request];
            NSLog(@"Downloaing issue %@ at %@", [issueData objectForKey:@"name"], contentUrl);
            [asset downloadWithDelegate:(id<NSURLConnectionDownloadDelegate>)self]; 
        }
    }
}

-(void) startDownloadingLatestIssue {
    [self startDownloadingIssue:[self getLastIssueFromDevice]];
}
    
#pragma mark - NSURLConnectionDownloadDelegate  

-(void) connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL  {
    NKAssetDownload *asset = connection.newsstandAssetDownload;
    NKIssue *issue = asset.issue;
    
    NSURL *issueContentPath = [issue.contentURL URLByAppendingPathComponent:@"IssueContent.pdf"];
    
    [[NSFileManager defaultManager] copyItemAtURL:destinationURL toURL:issueContentPath error:nil];
    
    // We need some error handling here just in case we couldn't copy the issue content.
    
    NSURL *issueDataPath = [issue.contentURL URLByAppendingPathComponent:@"issueData.plist"];
    NSMutableDictionary *issueData = [NSMutableDictionary dictionaryWithContentsOfURL:issueDataPath];
    
    [issueData setValue:[NSNumber numberWithBool:YES] forKey:@"contentWasDownloaded"];
    
    [issueData writeToURL:issueDataPath atomically:YES];
    
    [self.downloadDelegate connectionDidFinishDownloading:connection destinationURL:destinationURL];
}

-(void) connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes  {
    [self writeDownloadProgressToFile:connection withProgress:((float)totalBytesWritten / (float)expectedTotalBytes)];
    [self.downloadDelegate connection:connection didWriteData:bytesWritten totalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}

-(void) connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes  {
    
    [self writeDownloadProgressToFile:connection withProgress:((float)totalBytesWritten / (float)expectedTotalBytes)];    
    [self.downloadDelegate connectionDidResumeDownloading:connection totalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}

-(void) writeDownloadProgressToFile:(NSURLConnection *)connection withProgress:(float)progress  {
    NKAssetDownload *asset = connection.newsstandAssetDownload;
    NKIssue *issue = asset.issue;
    
    NSURL *issueDataPath = [issue.contentURL URLByAppendingPathComponent:@"issueData.plist"];
    NSMutableDictionary *issueData = [NSMutableDictionary dictionaryWithContentsOfURL:issueDataPath];
    
    [issueData setValue:[NSNumber numberWithFloat:progress] forKey:@"downloadProgress"];
    
    [issueData writeToURL:issueDataPath atomically:YES];
    NSLog(@"Writing progress of %f to the dictionary.", progress);
    
}


@end

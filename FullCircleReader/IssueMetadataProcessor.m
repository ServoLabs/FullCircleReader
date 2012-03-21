//
//  IssueMetadataProcessor.m
//  FullCircleReader
//
//  Created by Bryce Penberthy on 3/20/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//

#import "IssueMetadataProcessor.h"

@implementation IssueMetadataProcessor

+(NKIssue*) processIssueForDictionary:(NSDictionary*) metaData  {
    
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

+(NKIssue*) getLastIssueFromDevice  {
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
    
+(NKIssue*) findIssueWithDate:(NSDate*) pubDate  {
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

+(NSDateComponents*) buildDateComponentsFromDate:(NSDate *) dateValue  {
    NSCalendar *cal = [NSCalendar currentCalendar];
    return [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
                                     fromDate:dateValue];
    
}
    

@end

//
//  FCRAppDelegate.m
//  FullCircleReader
//
//  Created by Bryce Penberthy on 1/19/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//

#import "FCRAppDelegate.h"
#import <NewsstandKit/NewsstandKit.h>
#import "IssueMetadataProcessor.h"

NSString * const FCM_APP_KEY = @"FCM12345";
NSString * const PRESSROOM_URL = @"http://pressroom.servolabs.com";
NSString * const DEV_DEVICE = @"dev";
NSString * const PROD_DEVICE = @"prod";

@interface FCRAppDelegate()

- (void) checkForIssueUpdates;
- (void) retriveIssueList;
-(NSDate*) getLastIssueDateOnServer;
-(void) displayNetworkError:(NSError*) serviceError;

@end

@implementation FCRAppDelegate

@synthesize window = _window;
@synthesize updating = _updating;
@synthesize updateStatusDelegate = updateStatusDelegate;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[NSUserDefaults standardUserDefaults]setBool: YES forKey:@"NKDontThrottleNewsstandContentNotifications"];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge)];
    [self checkForIssueUpdates];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark Push Notification callback methods

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken  {
    NSString *deviceTokenString = [[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString: @">" withString: @""] ;
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSLog(@"Push Notification Token: %@", deviceTokenString);
    
    // Send the token to the server
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", PRESSROOM_URL, @"subcriberDevice/registerDevice"]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest 
									requestWithURL:url];
    
    NSString *params = [[NSString alloc] initWithFormat:@"pubAppKey=%@&token=%@&env=%@", FCM_APP_KEY, deviceTokenString, DEV_DEVICE];
    request.HTTPMethod = @"POST";
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request 
                                       queue:[[NSOperationQueue alloc] init] 
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (nil != error)  {
            NSLog(@"Couldn't register device!  %@", [error localizedDescription]);
        }
    }];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection  {
    NSLog(@"Finished communicating with the server");
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err  {
    NSLog(@"Couldn't register for remote notifications: %@", [err localizedDescription]);
}

- (void) checkForIssueUpdates  {

    self.updating = YES;
    [self.updateStatusDelegate startedUpdating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 
                                             (unsigned long)NULL), ^(void) {
        
        // Make a call to the Pressroom to find out what the last issue date is
        NSDate *latestServerDate = [self getLastIssueDateOnServer];

        if (nil != latestServerDate)  {
            NKIssue *issueForLatestServerDate = [IssueMetadataProcessor findIssueWithDate:latestServerDate];
            
            // Does the server have a newer issue?
            if (nil == issueForLatestServerDate)  {
                [self retriveIssueList];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.updating = NO;
            [self.updateStatusDelegate finishedUpdating];
        });
        
    });
    
        
}

- (void) retriveIssueList  {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/public/catalog?pubAppKey=%@", PRESSROOM_URL, FCM_APP_KEY]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest 
									requestWithURL:url];
    
    NSError* serviceError;

    NSData *serverResponse = [NSURLConnection sendSynchronousRequest:request 
                                                   returningResponse:nil
                                                               error:&serviceError];
    
    if (serviceError != nil)  {
        [self displayNetworkError:serviceError];
    } else  {
    
        NSDictionary *decodedResponse = [NSJSONSerialization JSONObjectWithData:serverResponse options:NSJSONReadingMutableContainers error:nil];
            
        NSArray *issueListData = [decodedResponse objectForKey:@"issues"];
        for (NSMutableDictionary *issueData in issueListData)  {
            // Convert the pubDate to an NSDate
            NSString *pubDateStr = [issueData objectForKey:@"pubDate"];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"MM/dd/yyyy"];
            [issueData setObject:[dateFormat dateFromString:pubDateStr] forKey:@"pubDate"];
            
            [IssueMetadataProcessor processIssueForDictionary:issueData];
        }
        
    }
}

-(NSDate*) getLastIssueDateOnServer  {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/public/lastIssueDate?pubAppKey=%@", PRESSROOM_URL, FCM_APP_KEY]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest 
									requestWithURL:url];
    NSError *serviceError;
    NSData *serverResponse = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&serviceError];
    
    if (nil != serviceError)  {
        if ([[[NKLibrary sharedLibrary] issues] count] == 0)  {
            [self displayNetworkError:serviceError];
        }
        return nil;
    } else  {
        NSDictionary *decodedResponse = [NSJSONSerialization JSONObjectWithData:serverResponse options:NSJSONReadingMutableContainers error:nil];

        NSString *serverDateStr = [decodedResponse objectForKey:@"lastIssueDate"];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
        return [dateFormat dateFromString:serverDateStr];
    }
}

-(void) displayNetworkError:(NSError*) serviceError  {
    NSString* message = [NSString stringWithFormat:@"Please check your Internet connection, then refresh your issue list. %@", [serviceError localizedDescription]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not get the issue list."
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end

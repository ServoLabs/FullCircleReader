//
//  FCRAppDelegate.m
//  FullCircleReader
//
//  Created by Bryce Penberthy on 1/19/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//

#import "FCRAppDelegate.h"

NSString * const FCM_APP_KEY = @"FCM12345";
NSString * const PRESSROOM_URL = @"http://pressroom.servolabs.com";
NSString * const DEV_DEVICE = @"dev";
NSString * const PROD_DEVICE = @"prod";

@implementation FCRAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[NSUserDefaults standardUserDefaults]setBool: YES forKey:@"NKDontThrottleNewsstandContentNotifications"];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge)];
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

@end

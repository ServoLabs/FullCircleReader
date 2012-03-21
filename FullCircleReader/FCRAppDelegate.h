//
//  FCRAppDelegate.h
//  FullCircleReader
//
//  Created by Bryce Penberthy on 1/19/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCRUpdateStatusDelegate.h"

@interface FCRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL updating;
@property (weak, nonatomic) id<FCRUpdateStatusDelegate> updateStatusDelegate;

@end

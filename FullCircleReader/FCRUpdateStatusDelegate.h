//
//  FCRUpdateStatusDelegate.h
//  FullCircleReader
//
//  Created by Bryce Penberthy on 3/20/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FCRUpdateStatusDelegate <NSObject>
-(void) startedUpdating;
-(void) finishedUpdating;
@end

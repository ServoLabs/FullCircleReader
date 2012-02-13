//
//  IssueCellView.h
//  FullCircleReader
//
//  Created by Bryce Penberthy on 2/11/12.
//  Copyright (c) 2012 Servo Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IssueCellView : UITableViewCell

@property(nonatomic, strong) IBOutlet UILabel *nameLabel;
@property(nonatomic, strong) IBOutlet UILabel *subTitleLabel;
@property(nonatomic, strong) IBOutlet UILabel *publicationDateLabel;
@property(nonatomic, strong) IBOutlet UIImageView *coverImage; 
@property(nonatomic, strong) IBOutlet UIImageView *statusIconImage;
@property(nonatomic, strong) IBOutlet UIProgressView *progressView;
@property(nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property(nonatomic, strong) IBOutlet UIButton *downloadButton;

@end

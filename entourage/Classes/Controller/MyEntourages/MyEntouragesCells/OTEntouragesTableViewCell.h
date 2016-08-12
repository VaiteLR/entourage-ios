//
//  OTEntouragesTableViewCell.h
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"
#import "OTSummaryProviderBehavior.h"

@interface OTEntouragesTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblDescription;
@property (nonatomic, weak) IBOutlet UILabel *lblTimeDistance;
@property (nonatomic, weak) IBOutlet UILabel *lblNumberOfUsers;
@property (nonatomic, weak) IBOutlet UIButton *btnProfilePicture;
@property (nonatomic, weak) IBOutlet UILabel *lblLastMessage;
@property (nonatomic, weak) IBOutlet OTSummaryProviderBehavior *summaryProvider;

- (void)configureWith:(OTFeedItem *)item;

@end
//
//  OTSummaryProviderBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTFeedItem.h"

@interface OTSummaryProviderBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblDescription;
@property (nonatomic, weak) IBOutlet UILabel *lblTimeDistance;
@property (nonatomic, weak) IBOutlet UIButton *btnAvatar;
@property (nonatomic, weak) IBOutlet UILabel *lblUserCount;
@property (nonatomic, weak) IBOutlet UITextView *txtFeedItemDescription;
@property (nonatomic, weak) IBOutlet UIImageView *imgAssociation;
@property (nonatomic, weak) IBOutlet UIImageView *imgCategory;

- (void)configureWith:(OTFeedItem *)feedItem;
- (void)clearConfiguration;

@property (nonatomic, strong) NSNumber *fontSize;

+ (NSString *)toDistance:(double)distance;

@end

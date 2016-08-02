//
//  OTFeedItemSummaryView.m
//  entourage
//
//  Created by Ciprian Habuc on 20/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemSummaryView.h"
#import "OTEntourage.h"
#import "OTTour.h"
#import "UILabel+entourage.h"
#import "UIButton+entourage.h"
#import "OTFeedItemFactory.h"
#import "OTUIDelegate.h"

#define FEEDITEM_SUMMAY_TAG 1
#define FEEDITEM_TYPE_BY_NAME_TAG 2
#define FEEDITEM_AVATAR_TAG 3

@implementation OTFeedItemSummaryView

- (void)setupWithFeedItem:(OTFeedItem *)feedItem {
    id<OTUIDelegate> uiDelegate = [[OTFeedItemFactory createFor:feedItem] getUI];
    
    UILabel *summaryLabel = [self viewWithTag:FEEDITEM_SUMMAY_TAG];
    summaryLabel.text = [uiDelegate summary];
    
    UILabel *typeByNameLabel = [self viewWithTag:FEEDITEM_TYPE_BY_NAME_TAG];
    typeByNameLabel.attributedText = [uiDelegate descriptionWithSize:DEFAULT_DESCRIPTION_SIZE];

    UIButton *userImageButton = [self viewWithTag:FEEDITEM_AVATAR_TAG];
    [userImageButton setupAsProfilePictureFromUrl:feedItem.author.avatarUrl];
    [userImageButton addTarget:self action:@selector(doShowProfile:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)doShowProfile:(UIButton *)senderButton {
    if ([self.delegate respondsToSelector:@selector(doShowProfile)])
        [ self.delegate performSelector:@selector(doShowProfile)];
}


@end

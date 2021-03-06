//
//  OTEntouragesTableViewCell.m
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntouragesTableViewCell.h"
#import "UIColor+entourage.h"
#import "OTTableDataSourceBehavior.h"

@implementation OTEntouragesTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lblNumberOfUsers.layer.borderColor = [UIColor appGreyishColor].CGColor;
}

- (void)configureWith:(OTFeedItem *)item {
    self.summaryProvider.lblTitle = self.lblTitle;
    self.summaryProvider.lblDescription = self.lblDescription;
    self.summaryProvider.lblUserCount = self.lblNumberOfUsers;
    self.summaryProvider.btnAvatar = self.btnProfilePicture;
    self.summaryProvider.lblTimeDistance = self.lblTimeDistance;
    self.summaryProvider.imgAssociation = self.imgAssociation;
    self.summaryProvider.imgCategory = self.imgCategory;
    [self.summaryProvider configureWith:item];
    [self.summaryProvider clearConfiguration];
    if(item.unreadMessageCount.intValue > 0) {
       self.lblLastMessage.font = [UIFont fontWithName:@"SFUIText-Medium" size:self.lblLastMessage.font.pointSize];
       self.lblLastMessage.textColor = [UIColor blackColor];
    }
    else {
        self.lblLastMessage.font = [UIFont fontWithName:@"SFUIText-Light" size:self.lblLastMessage.font.pointSize];
        self.lblLastMessage.textColor = [UIColor appGreyishColor];
    }
    self.lblLastMessage.text = [self getAuthorTextFor:item.lastMessage];
    self.txtUnreadCount.hidden = item.unreadMessageCount.intValue == 0;
    self.txtUnreadCount.text = item.unreadMessageCount.stringValue;
}

- (IBAction)showUserDetails:(id)sender {
    [OTLogger logEvent:@"UserProfileClick"];
    NSIndexPath *indexPath = [self.dataSource.tableView indexPathForCell:self];
    OTFeedItem *feedItem = [self.dataSource.tableDataSource getItemAtIndexPath:indexPath];
    [self.userProfile showProfile:feedItem.author.uID];
}

#pragma mark - private methods

- (NSString *)getAuthorTextFor:(OTMyFeedMessage *)lastMessage {
    NSMutableString *result = [NSMutableString new];
    if(lastMessage.firstName.length > 0)
        [result appendString:lastMessage.firstName];
    if(lastMessage.lastName.length > 0)
        [result appendFormat:@" %@", [lastMessage.lastName substringToIndex:1]];
    if(result.length > 0)
        [result appendString:@": "];
    if(lastMessage.text)
        [result appendString:lastMessage.text];
    return result;
}

@end

//
//  OTEntourageStateInfo.m
//  entourage
//
//  Created by sergiu buceac on 6/17/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageStateInfo.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "OTEntourageService.h"

@implementation OTEntourageStateInfo

- (FeedItemState)getState {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if ([currentUser.sid intValue] == [self.entourage.author.uID intValue]) {
        if ([ENTOURAGE_STATUS_OPEN isEqualToString:self.entourage.status])
            return FeedItemStateOpen;
        else
            return FeedItemStateClosed;
    }
    else {
        if([JOIN_NOT_REQUESTED isEqualToString:self.entourage.joinStatus])
            return FeedItemStateJoinNotRequested;
        else if([JOIN_ACCEPTED isEqualToString:self.entourage.joinStatus])
            return FeedItemStateJoinAccepted;
        else if([JOIN_PENDING isEqualToString:self.entourage.joinStatus])
            return FeedItemStateJoinPending;
        else if([JOIN_REJECTED isEqualToString:self.entourage.joinStatus])
            return FeedItemStateJoinRejected;
    }
    return FeedItemStateNone;
}

- (BOOL)canChangeEditState {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if ([currentUser.sid intValue] == [self.entourage.author.uID intValue])
        return ![self.entourage.status isEqualToString:FEEDITEM_STATUS_CLOSED];
    else
        return [self.entourage.joinStatus isEqualToString:JOIN_ACCEPTED];
    return NO;
}

- (BOOL)canInvite {
    return YES;
}

- (BOOL)isActive {
    return [self.entourage.status isEqualToString:ENTOURAGE_STATUS_OPEN];
}

- (BOOL)isPublic {
    if([self.entourage.status isEqualToString:FEEDITEM_STATUS_CLOSED])
        return YES;
    return ![self.entourage.joinStatus isEqualToString:JOIN_ACCEPTED];
}

- (BOOL)canEdit {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    return [self.entourage.status isEqualToString:ENTOURAGE_STATUS_OPEN] && [currentUser.sid intValue] == [self.entourage.author.uID intValue];
}

- (void)loadWithSuccess:(void(^)(OTFeedItem *))success error:(void(^)(NSError *))failure {
    [[OTEntourageService new] getEntourageWithId:self.entourage.uid withSuccess:^(OTEntourage *entourage) {
       if(success)
           success(entourage);
    } failure:^(NSError *error) {
        if(failure)
            failure(error);
    }];
}

@end

//
//  OTNextStatusButtonBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/6/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTNextStatusButtonBehavior.h"
#import "OTFeedItemFactory.h"
#import "OTConsts.h"
#import "SVProgressHUD.h"
#import "OTTour.h"

@interface OTNextStatusButtonBehavior ()

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, weak) id<OTStatusChangedProtocol> delegate;

@end

@implementation OTNextStatusButtonBehavior

- (void)configureWith:(OTFeedItem *)feedItem andProtocol:(id<OTStatusChangedProtocol>)protocol {
    self.feedItem = feedItem;
    self.delegate = protocol;
    [self updateButton];
}

#pragma mark - private methods

- (void)updateButton {
    FeedItemState currentState = [[[OTFeedItemFactory createFor:self.feedItem] getStateInfo] getState];
    NSString *title = nil;
    SEL selector = nil;
    self.btnNextState.hidden = YES;
    switch (currentState) {
        case FeedItemStateOngoing:
            title = OTLocalizedString(@"item_option_close");
            selector = @selector(doStopFeedItem);
            self.btnNextState.hidden = NO;
            break;
        case FeedItemStateOpen:
            title = OTLocalizedString(@"item_option_freeze");
            selector = @selector(doCloseFeedItem);
            self.btnNextState.hidden = NO;
            break;
        case FeedItemStateClosed:
            if([self.feedItem isKindOfClass:[OTTour class]]) {
                title = OTLocalizedString(@"item_option_freeze");
                selector = @selector(doCloseFeedItem);
                self.btnNextState.hidden = NO;
            }
            break;
        case FeedItemStateJoinAccepted:
            title = OTLocalizedString(@"item_option_quit");
            selector = @selector(doQuitFeedItem);
            self.btnNextState.hidden = NO;
            break;
        case FeedItemStateJoinNotRequested:
            title = OTLocalizedString(@"join");
            selector = @selector(doJoinFeedItem);
            self.btnNextState.hidden = NO;
            break;
        case FeedItemStateJoinPending:
            title = OTLocalizedString(@"item_cancel_join");
            selector = @selector(doQuitFeedItem);
            self.btnNextState.hidden = NO;
            break;
        default:
            break;
    }
    [self.btnNextState addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.btnNextState setTitle:title forState:UIControlStateNormal];
}

#pragma mark - state transitions

- (void)doStopFeedItem {
    [OTLogger logEvent:@"StopEntourageConfirm"];
    [SVProgressHUD show];
    [[[OTFeedItemFactory createFor:self.feedItem] getStateTransition] stopWithSuccess:^() {
        [SVProgressHUD dismiss];
        [self.owner dismissViewControllerAnimated:NO completion:^{
            if(self.delegate)
                [self.delegate stoppedFeedItem];
        }];
    } orFailure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"generic_error")];
    }];
}

- (void)doCloseFeedItem {
    [OTLogger logEvent:@"CloseEntourageConfirm"];
    [SVProgressHUD show];
//    [self.owner performSegueWithIdentifier:@"ConfirmCloseSegue" sender:self];
//    return;
    [[[OTFeedItemFactory createFor:self.feedItem] getStateTransition] closeWithSuccess:^(BOOL isTour) {
        [SVProgressHUD dismiss];
        [self.owner dismissViewControllerAnimated:NO completion:^{
            if(self.delegate)
                [self.delegate closedFeedItem];
        }];
    } orFailure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"generic_error")];
    }];
}

- (void)doQuitFeedItem {
    [OTLogger logEvent:@"ExitEntourageConfirm"];
    [SVProgressHUD show];
    [[[OTFeedItemFactory createFor:self.feedItem] getStateTransition] quitWithSuccess:^() {
        [SVProgressHUD dismiss];
        [self.owner dismissViewControllerAnimated:NO completion:^{
            if(self.delegate)
                [self.delegate closedFeedItem];
        }];
    } orFailure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"generic_error")];
    }];
}

- (void)doJoinFeedItem {
    if(self.delegate)
        [self.delegate joinFeedItem];
}

@end

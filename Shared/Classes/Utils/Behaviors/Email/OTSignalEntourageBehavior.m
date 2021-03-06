//
//  OTSignalEntourageBehavior.m
//  entourage
//
//  Created by sergiu buceac on 11/22/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTSignalEntourageBehavior.h"
#import <MessageUI/MessageUI.h>
#import "OTConsts.h"
#import "SVProgressHUD.h"

#define SIGNAL_ENTOURAGE_TO @"contact@entourage.social"

@interface OTSignalEntourageBehavior () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) MFMailComposeViewController *mailController;

@end

@implementation OTSignalEntourageBehavior

- (void)sendMailFor:(OTEntourage *)entourage {
    NSString *subject = [NSString stringWithFormat:OTLocalizedString(@"mail_signal_subject"), entourage.title, entourage.author.displayName];
    [self sendMailWithSubject:subject];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.mailController dismissViewControllerAnimated:YES completion:^() {
        [self.owner dismissViewControllerAnimated:YES completion:^() {
            if(result == MFMailComposeResultSent)
                [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"mail_sent")];
            else if(result != MFMailComposeResultCancelled)
                [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"mail_send_failure")];
        }];
    }];
}

#pragma mark - private methods

- (void)sendMailWithSubject:(NSString *)subject {
    if([MFMailComposeViewController canSendMail]) {
        self.mailController = [MFMailComposeViewController new];
        [self.mailController setToRecipients:@[SIGNAL_ENTOURAGE_TO]];
        [self.mailController setSubject:subject];
        self.mailController.mailComposeDelegate = self;
        [self.owner showViewController:self.mailController sender:self];
    }
    else
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"mail_not_configured")];
}

@end

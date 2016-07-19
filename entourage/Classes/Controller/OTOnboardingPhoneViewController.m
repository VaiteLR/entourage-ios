//
//  OTOnboardingPhoneViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 06/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTOnboardingPhoneViewController.h"
#import "IQKeyboardManager.h"
#import "UITextField+indentation.h"
#import "UIView+entourage.h"
#import "OTOnboardingService.h"
#import "SVProgressHUD.h"
#import "OTConsts.h"
#import "NSUserDefaults+OT.h"
#import "UIScrollView+entourage.h"
#import "NSError+message.h"

@interface OTOnboardingPhoneViewController ()

@property (nonatomic, weak) IBOutlet UITextField *phoneTextField;
@property (nonatomic, weak) IBOutlet UIButton *continueButton;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *heightContraint;

@end

@implementation OTOnboardingPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"";
    
    [self.phoneTextField setupWithWhitePlaceholder];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [self.continueButton setupHalfRoundedCorners];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showKeyboard:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
#if DEBUG //TARGET_IPHONE_SIMULATOR
    self.phoneTextField.text = @"+40723199641";
#endif
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self.phoneTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doContinue {
    OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    
    NSString *phone = self.phoneTextField.text;
    currentUser.phone = phone;
    
    [SVProgressHUD show];
    [[OTOnboardingService new] setupNewUserWithPhone:phone
        success:^(OTUser *onboardUser) {
            [SVProgressHUD dismiss];
            onboardUser.phone = phone;
            [[NSUserDefaults standardUserDefaults] setCurrentUser:onboardUser];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self performSegueWithIdentifier:@"PhoneToCodeSegue" sender:nil];
        } failure:^(NSError *error) {
            NSString *errorMessage = [error userUpdateMessage];
#warning Create special message(code) on server-side
            if ([errorMessage isEqualToString:@"Phone n'est pas disponible"]) {
                [SVProgressHUD dismiss];
                [[NSUserDefaults standardUserDefaults] setCurrentUser:currentUser];
                [[NSUserDefaults standardUserDefaults] synchronize];

                [self performSegueWithIdentifier:@"PhoneToCodeSegue" sender:nil];
            } else {
                [SVProgressHUD showErrorWithStatus:errorMessage];
            }
            NSLog(@"ERR: something went wrong on onboarding user phone: %@", error.description);
        }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showKeyboard:(NSNotification*)notification {
    //[self.scrollView scrollToBottomFromKeyboardNotification:notification];
    [self.scrollView scrollToBottomFromKeyboardNotification:notification andHeightContraint:self.heightContraint];

}

@end

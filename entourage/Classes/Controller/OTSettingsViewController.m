//
//  OTSettingsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 24/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTSettingsViewController.h"
#import "UIViewController+menu.h"
#import "OTConsts.h"


#define TAG_S_HOWRECENT 1
#define TAG_TF_HOWRECENT 2
#define TAG_S_DISTANCE 3
#define TAG_TF_DISTANCE 4
#define TAG_TF_ACCURACY 5


@interface OTSettingsViewController() <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UISwitch *shouldUseHowRecentSwitch;
@property (nonatomic, weak) IBOutlet UITextField *maxHowRecentValueTextField;
@property (nonatomic, weak) IBOutlet UISwitch *shouldUseDistanceSwitch;
@property (nonatomic, weak) IBOutlet UITextField *minDistanceTextField;
@property (nonatomic, weak) IBOutlet UITextField *accuracyTextField;

@end

@implementation OTSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = OTLocalizedString( @"parameters").uppercaseString;
    [self setupCloseModal];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    _shouldUseHowRecentSwitch.on = [standardUserDefaults boolForKey:@"shouldUseHowRecent"];
    _maxHowRecentValueTextField.enabled = _shouldUseHowRecentSwitch.isOn;
    NSNumber *howRecentValue = [standardUserDefaults valueForKey:@"maxHowRecentValue"];
    _maxHowRecentValueTextField.text = [NSString stringWithFormat:@"%.0f", howRecentValue.doubleValue];
    
    _shouldUseDistanceSwitch.on = [standardUserDefaults boolForKey:@"shouldUseDistance"];
    _minDistanceTextField.enabled = _shouldUseDistanceSwitch.isOn;
    NSNumber *distanceValue = [standardUserDefaults valueForKey:@"minDistance"];
    _minDistanceTextField.text = [NSString stringWithFormat:@"%.0f", distanceValue.doubleValue];
     NSNumber *accuracyValue = [standardUserDefaults valueForKey:@"accuracy"];
    _accuracyTextField.text = [NSString stringWithFormat:@"%.0f", accuracyValue.doubleValue];
}

#pragma mark - UISwitchDelegate

- (IBAction)valueDidChange:(UISwitch*)mySwitch {
    BOOL updatedValue = mySwitch.isOn;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (mySwitch.tag == TAG_S_HOWRECENT) {
        [standardUserDefaults setBool:updatedValue forKey:@"shouldUseHowRecent"];
        _maxHowRecentValueTextField.enabled = updatedValue;
    }
    if (mySwitch.tag == TAG_S_DISTANCE) {
        [standardUserDefaults setBool:updatedValue forKey:@"shouldUseDistance"];
        _minDistanceTextField.enabled = updatedValue;
    }
    [standardUserDefaults synchronize];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    double value = [textField.text doubleValue];
    NSNumber *valueNumber = [NSNumber numberWithDouble:value];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (textField.tag == TAG_TF_HOWRECENT) {
        [standardUserDefaults setValue:valueNumber forKey:@"maxHowRecentValue"];
    }
    if (textField.tag == TAG_TF_DISTANCE) {
        [standardUserDefaults setValue:valueNumber forKey:@"minDistance"];
    }
    if (textField.tag == TAG_TF_ACCURACY) {
        [standardUserDefaults setValue:valueNumber forKey:@"accuracy"];
    }
    [standardUserDefaults synchronize];

}

@end



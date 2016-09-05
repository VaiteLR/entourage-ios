//
//  OTDisclaimerBaseBehavior.h
//  entourage
//
//  Created by sergiu buceac on 9/5/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"

@interface OTDisclaimerBaseBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;

- (void)showDisclaimer;
- (BOOL)prepareSegue:(UIStoryboardSegue *)segue;

- (NSString *)disclaimerText;
- (NSString *)disclaimerStorageKey;
- (BOOL)wasDisclaimerAccepted;

@end
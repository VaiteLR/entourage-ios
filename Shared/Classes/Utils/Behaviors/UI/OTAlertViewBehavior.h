//
//  OTAlertViewBehavior.h
//  entourage
//
//  Created by veronica.gliga on 07/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"

@interface OTAlertViewBehavior : OTBehavior

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;

- (void)addAction:(NSString *)title delegate:(void (^)(void))delegate;
- (void)show;

+ (void)setupOngoingCreateEntourageWithAction:(OTAlertViewBehavior *)action;

@end

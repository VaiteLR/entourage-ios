//
//  OTPushNotificationsService.h
//  entourage
//
//  Created by sergiu buceac on 8/26/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTPushNotificationsService : NSObject

- (void)sendAppInfo;
- (void)saveToken:(NSData *)tokenData;
- (void)handleRemoteNotification:(NSDictionary *)userInfo;
- (void)handleLocalNotification:(NSDictionary *)userInfo;

@end

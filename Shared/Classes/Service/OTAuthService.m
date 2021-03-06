//
//  OTUserServices.m
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTAuthService.h"

// Pods
#import <AFNetworking/AFNetworking.h>
#import "SimpleKeychain.h"

// Manager
#import "OTHTTPRequestManager.h"

// Helper
#import "NSUserDefaults+OT.h"
#import "NSDictionary+Parsing.h"
#import "NSBundle+entourage.h"

// Model
#import "OTUser.h"
#import "OTOrganization.h"
#import "OTConsts.h"
#import "OTAPIConsts.h"

#import <Crashlytics/Crashlytics.h>

/**************************************************************************************************/
#pragma mark - Constants

NSString *const kAPIApps = @"applications";

NSString *const kAPILogin = @"login";
NSString *const kAPIUserRoute = @"users";
NSString *const kAPIUpdateUserRoute = @"update_me";
NSString *const kAPIMe = @"me";
NSString *const kAPICode = @"code";
NSString *const kKeychainPhone = @"entourage_user_phone";
NSString *const kKeychainPassword = @"entourage_user_password";

/**************************************************************************************************/
#pragma mark - Public methods

@implementation OTAuthService

- (void)authWithPhone:(NSString *)phone
             password:(NSString *)password
             deviceId:(NSString *)deviceId
              success:(void (^)(OTUser *))success
              failure:(void (^)(NSError *))failure
{
    if (phone == nil || password == nil) {
        if (failure) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: OTLocalizedString(@"generic_error")};
            failure([NSError errorWithDomain:@"entourageError" code:-1 userInfo:userInfo]);
        }
    }
    NSDictionary *parameters = @{@"user": @{@"phone": phone, @"sms_code": password}};
    OTRequestOperationManager *requestManager = [OTHTTPRequestManager sharedInstance];
    [requestManager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSLog(@"Login with user %@. DeviceID = %@", parameters, deviceId);
    //NSLog(@"Login header: %@", requestManager.requestSerializer.HTTPRequestHeaders);
    [requestManager
         POSTWithUrl:kAPILogin
         andParameters:parameters
         andSuccess:^(id responseObject) {
             NSDictionary *responseDict = responseObject;
             NSLog(@"Authentication service response : %@", responseDict);
             NSDictionary *responseUser = responseDict[@"user"];
             OTUser *user = [[OTUser alloc] initWithDictionary:responseUser];
             
             [[A0SimpleKeychain keychain] setString:phone forKey:kKeychainPhone];
             [[A0SimpleKeychain keychain] setString:password forKey:kKeychainPassword];
             
             if (success) {
                 success(user);
             }
         }
         andFailure:^(NSError *error)
         {
             [[Crashlytics sharedInstance] recordError:error withAdditionalUserInfo:parameters];
             NSLog(@"Failed with error %@", error);
             if (failure) {
                 failure(error);
             }
     }];
}

- (void)deleteAccountForUser:(NSNumber *)userID
                     success:(void (^)())success
                     failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_DELETE_ACCOUNT, TOKEN];
    
    [[OTHTTPRequestManager sharedInstance]
         DELETEWithUrl:url
         andParameters:nil
         andSuccess:^(id responseObject) {
             if (success) {
                 success();
             }
         }
         andFailure:^(NSError *error)
         {
             NSLog(@"Failed with error %@", error);
             if (failure) {
                 failure(error);
             }
         }];

}

- (void)getDetailsForUser:(NSNumber *)userID
              success:(void (^)(OTUser *))success
              failure:(void (^)(NSError *))failure
{
    
    NSString *url = [NSString stringWithFormat:API_URL_USER_DETAILS, userID, TOKEN];
    
    [[OTHTTPRequestManager sharedInstance]
         GETWithUrl:url
         andParameters:nil
         andSuccess:^(id responseObject) {
             NSDictionary *responseDict = responseObject;
             NSDictionary *responseUser = responseDict[@"user"];
             OTUser *user = [[OTUser alloc] initWithDictionary:responseUser];
             
             if (success) {
                 success(user);
             }
         }
         andFailure:^(NSError *error)
         {
             NSLog(@"Failed with error %@", error);
             if (failure) {
                 failure(error);
             }
         }];
}

- (void)sendAppInfoWithSuccess:(void (^)())success
                       failure:(void (^)(NSError *))failure
{
    NSString *pushToken = [[NSUserDefaults standardUserDefaults] objectForKey:@DEVICE_TOKEN_KEY];
    if (!pushToken)
        return;

    NSString *deviceiOS = [NSString stringWithFormat:@"iOS %@",[[NSProcessInfo processInfo] operatingSystemVersionString]];
    
    NSString *version = [NSBundle currentVersion];
    NSDictionary *parameters =  @{@"application": @{@"push_token": pushToken, @"device_os" : deviceiOS, @"version" : version}};
                                    
    
    NSString *url = [NSString stringWithFormat:@"%@?token=%@", kAPIApps, TOKEN];
    NSLog(@"Applications: %@\n%@", url, parameters);
    
    [[OTHTTPRequestManager sharedInstance]
         PUTWithUrl:url
         andParameters:parameters
         andSuccess:^(id responseObject) {
             if (success) {
                 success();
             }
         }
         andFailure:^(NSError *error)
         {
             NSLog(@"Failed with error %@", error);
             if (failure) {
                 failure(error);
             }
         }];
}

- (void)regenerateSecretCode:(NSString *)phone
                     success:(void (^)(OTUser *))success
                     failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_REGENERATE_CODE, kAPIUserRoute, kAPIMe, kAPICode];
    
    NSMutableDictionary *phoneDictionnary = [NSMutableDictionary new];
    phoneDictionnary[@"phone"] = phone;
    
    NSMutableDictionary *actionDictionnary = [NSMutableDictionary new];
    actionDictionnary[@"action"] = @"regenerate";
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"user"] = phoneDictionnary;
    parameters[@"code"] = actionDictionnary;
    
    [[OTHTTPRequestManager sharedInstance]
     PATCHWithUrl:url andParameters:parameters
     andSuccess:^(id responseObject)
     {
         NSDictionary *responseDict = responseObject;
         NSDictionary *responseUser = responseDict[@"user"];
         OTUser *user = [[OTUser alloc] initWithDictionary:responseUser];
         if (success) {
             success(user);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure) {
             failure(error);
         }
     }];
}

- (void)updateUserInformationWithEmail:(NSString *)email
                            andSmsCode:(NSString *)smsCode
                               success:(void (^)(NSString *))success
                               failure:(void (^)(NSError *))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_UPDATE_USER, kAPIUserRoute, kAPIMe, TOKEN];
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    dictionary[@"email"] = email;
    dictionary[@"sms_code"] = smsCode;
    
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[@"user"] = dictionary;
    
    [[OTHTTPRequestManager sharedInstance]
     PATCHWithUrl:url andParameters:parameters
     andSuccess:^(id responseObject)
     {
         if (success) {
             NSDictionary *responseDict = responseObject;
             NSDictionary *responseUser = responseDict[@"user"];
             success([responseUser stringForKey:@"email"]);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure) {
             failure(error);
         }
     }];
}

- (void)updateUserInformationWithUser:(OTUser *)user
                              success:(void (^)(OTUser *user))success
                              failure:(void (^)(NSError *error))failure
{
    NSString *url = [NSString stringWithFormat:API_URL_UPDATE_USER, kAPIUserRoute, kAPIMe, TOKEN];
    
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[@"user"] = [user dictionaryForWebservice];
    
    [[OTHTTPRequestManager sharedInstance]
            PATCHWithUrl:url
            andParameters:parameters
            andSuccess:^(id responseObject)
         {
             if (success) {
                 // CHECK THIS
                 NSDictionary *responseDict = responseObject;
                 NSDictionary *responseUser = responseDict[@"user"];
                 OTUser *user = [[OTUser alloc] initWithDictionary:responseUser];
                 success(user);
             }
         }
         andFailure:^(NSError *error)
         {
             if (failure) {
                 failure(error);
             }
         }];
}

- (void)subscribeToNewsletterWithEmail:(NSString *)email
                               success:(void (^)(BOOL))success
                               failure:(void (^)(NSError *))failure
{
    NSDictionary *dict = @{ @"email": email, @"active": @"true" };
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"newsletter_subscription"] = dict;
    
    [[OTHTTPRequestManager sharedInstance]
     POSTWithUrl:@"newsletter_subscriptions" andParameters:parameters
     andSuccess:^(id responseObject)
     {
         if (success) {
             success(YES);
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure) {
             failure(error);
         }
     }];
}

- (void)checkVersionWithSuccess:(void (^)(BOOL))success
                        failure:(void (^)(NSError *))failure
{
    [[OTHTTPRequestManager sharedInstance]
     GETWithUrl:@"check"
     andParameters:nil
     andSuccess:^(id responseObject)
     {
         NSString *status = [responseObject stringForKey:@"status"];
         if (success) {
             if ([status isEqualToString:@"ok"]) {
                 success(YES);
             } else {
                 success(NO);
             }
         }
     }
     andFailure:^(NSError *error)
     {
         if (failure) {
             failure(error);
         }
     }];
}

@end

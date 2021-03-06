//
//  OTEntourageService.h
//  entourage
//
//  Created by Mihai Ionescu on 19/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "OTFeedItemMessage.h"

@class OTEntourage, OTFeedItemJoiner;

@interface OTEntourageService : NSObject

- (void)entouragesAroundCoordinate:(CLLocationCoordinate2D)coordinate
                           success:(void (^)(NSArray *))success
                           failure:(void (^)(NSError *))failure;

- (void)getEntourageWithId:(NSNumber *)entourageId
          withSuccess:(void(^)(OTEntourage *))success
              failure:(void (^)(NSError *))failure;

- (void)getEntourageWithStringId:(NSString *)entourageId
                     withSuccess:(void(^)(OTEntourage *))success
                         failure:(void (^)(NSError *))failure;

- (void)joinEntourage:(OTEntourage *)entourage
              success:(void(^)(OTFeedItemJoiner *))success
              failure:(void (^)(NSError *)) failure;

- (void)joinMessageEntourage:(OTEntourage *)entourage
                     message:(NSString *)message
                     success:(void(^)(OTFeedItemJoiner *))success
                     failure:(void (^)(NSError *)) failure;

- (void)closeEntourage:(OTEntourage *)entourage
           withSuccess:(void (^)(OTEntourage *))success
               failure:(void (^)(NSError *))failure;

- (void)updateEntourageJoinRequestStatus:(NSString *)status
                                 forUser:(NSNumber*)userID
                            forEntourage:(NSNumber*)entourageID
                             withSuccess:(void (^)())success
                                 failure:(void (^)(NSError *))failure;

- (void)rejectEntourageJoinRequestForUser:(NSNumber*)userID
                             forEntourage:(NSNumber*)entourageID
                              withSuccess:(void (^)())success
                                  failure:(void (^)(NSError *))failure;

- (void)sendMessage:(NSString *)message
        onEntourage:(OTEntourage *)entourage
            success:(void(^)(OTFeedItemMessage *))success
            failure:(void (^)(NSError *)) failure;

- (void)entourageMessagesForEntourage:(NSNumber *)entourageID
                          WithSuccess:(void(^)(NSArray *entourageMessages))success
                              failure:(void (^)(NSError *)) failure;

- (void)quitEntourage:(OTEntourage *)entourage
         success:(void (^)())success
         failure:(void (^)(NSError *error))failure;

- (void)entourageUsers:(OTEntourage *)entourage
               success:(void (^)(NSArray *))success
               failure:(void (^)(NSError *))failure;

- (void)readEntourageMessages:(NSNumber *)entourageID
                      success:(void (^)())success
                      failure:(void (^)(NSError *))failure;

- (void)retrieveEntourage:(OTEntourage *)entourage
                 fromRank:(NSNumber *)rank
                  success:(void (^)())success
                  failure:(void (^)(NSError *))failure;
@end

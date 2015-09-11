//
//  OTTourService.h
//  entourage
//
//  Created by Nicolas Telera on 31/08/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class OTTour;

extern NSString *const kAPITourRoute;

@interface OTTourService : NSObject

- (void)sendTour:(OTTour *)tour withSuccess:(void (^)(OTTour *sentTour))success failure:(void (^)(NSError *error))failure;

- (void)closeTour:(OTTour *)tour withSuccess:(void (^)(OTTour *closedTour))success failure:(void (^)(NSError *error))failure;

- (void)sendTourPoint:(NSMutableArray *)tourPoints withTourId:(NSNumber *)tourId withSuccess:(void (^)(OTTour *updatedTour))success failure:(void (^)(NSError *error))failure;

- (void)toursAroundCoordinate:(CLLocationCoordinate2D) coordinates
                               limit:(NSNumber *)limit
                            distance:(CLLocationDistance)distance
                             success:(void (^)(NSMutableArray *closeTours))success
                             failure:(void (^)(NSError *error))failure;

@end

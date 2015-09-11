//
//  OTTourService.m
//  entourage
//
//  Created by Nicolas Telera on 31/08/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import "OTTourService.h"
#import "OTHTTPRequestManager.h"
#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"

/**************************************************************************************************/
#pragma mark - Constants

NSString *const kAPITourRoute = @"tours";
NSString *const kTour = @"tour";
NSString *const kTours = @"tours";
NSString *const kTourPoints = @"tour_points";

@implementation  OTTourService

/**************************************************************************************************/
#pragma mark - Public methods

- (void)sendTour:(OTTour *)tour
     withSuccess:(void (^)(OTTour *receivedTour))success
         failure:(void (^)(NSError *error))failure
{
    NSString *url = [NSString stringWithFormat:@"%@.json?token=%@", kAPITourRoute, [[NSUserDefaults standardUserDefaults] currentUser].token];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[kTour] = [tour dictionaryForWebserviceTour];
    [[OTHTTPRequestManager sharedInstance] POST:url
                                     parameters:parameters
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         if (success)
                                         {
                                             OTTour *updatedTour = [self tourFromDictionary:responseObject];
                                             success(updatedTour);
                                         }
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         if (failure)
                                         {
                                             failure(error);
                                         }
                                     }];
}

- (void)closeTour:(OTTour *)tour
      withSuccess:(void (^)(OTTour *closedTour))success
          failure:(void (^)(NSError *error))failure
{
    NSString *url = [NSString stringWithFormat:@"%@/%@.json?token=%@", kAPITourRoute, [tour sid], [[NSUserDefaults standardUserDefaults] currentUser].token];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[kTour] = [tour dictionaryForWebserviceTour];
    [[OTHTTPRequestManager sharedInstance] PUT:url
                                    parameters:parameters
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                           if (success)
                                           {
                                               OTTour *updatedTour = [self tourFromDictionary:responseObject];
                                               success(updatedTour);
                                           }
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           if (failure)
                                           {
                                               failure(error);
                                           }
                                       }];
}

- (void)sendTourPoint:(NSMutableArray *)tourPoints
           withTourId:(NSNumber *)tourId
          withSuccess:(void (^)(OTTour *updatedTour))success
              failure:(void (^)(NSError *error))failure
{
    NSString *url = [NSString stringWithFormat:@"%@/%@/%@.json?token=%@", kAPITourRoute, tourId, kTourPoints, [[NSUserDefaults standardUserDefaults] currentUser].token];
    NSMutableDictionary *parameters = [[OTHTTPRequestManager commonParameters] mutableCopy];
    parameters[kTourPoints] = [OTTourPoint arrayForWebservice:tourPoints];
    [[OTHTTPRequestManager sharedInstance] POST:url
                                     parameters:parameters
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            if (success)
                                            {
                                                OTTour *updatedTour = [self tourFromDictionary:responseObject];
                                                success(updatedTour);
                                            }
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            if (failure)
                                            {
                                                failure(error);
                                            }
                                        }];
    
}

- (void)toursAroundCoordinate:(CLLocationCoordinate2D) coordinates
                               limit:(NSNumber *)limit
                            distance:(CLLocationDistance)distance
                             success:(void (^)(NSMutableArray *closeTours))success
                             failure:(void (^)(NSError *error))failure;
{
    NSString *url = [NSString stringWithFormat:@"%@.json?token=%@", kAPITourRoute, [[NSUserDefaults standardUserDefaults] currentUser].token];
    NSDictionary *parameters = @{ @"limit": limit, @"latitude": @(coordinates.latitude), @"longitude": @(coordinates.longitude), @"distance": @(distance) };
    [[OTHTTPRequestManager sharedInstance] GET:url
                                    parameters:parameters
                                       success:^(AFHTTPRequestOperation *operation, id responseObject)
                                       {
                                           NSDictionary *data = responseObject;
                                           NSMutableArray *tours = [self toursFromDictionary:data];
                                           
                                           if (success)
                                           {
                                               success(tours);
                                           }
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           if (failure)
                                           {
                                               failure(error);
                                           }
                                       }];
}

/**************************************************************************************************/
#pragma mark - Private methods

- (OTTour *)tourFromDictionary:(NSDictionary *)data
{
    OTTour *tour;
    NSDictionary *jsonTour = data[kTour];
    
    if ([jsonTour isKindOfClass:[NSDictionary class]])
    {
        tour = [OTTour tourWithJSONDictionary:jsonTour];
    }
    return tour;
}

- (NSMutableArray *)toursFromDictionary:(NSDictionary *)data
{
    NSMutableArray *tours = [NSMutableArray new];
    NSArray *jsonTours = data[kTours];
    
    if ([jsonTours isKindOfClass:[NSArray class]])
    {
        for (NSDictionary *dictionary in jsonTours)
        {
            OTTour *tour = [OTTour tourWithJSONDictionary:dictionary];
            if (tour)
            {
                [tours addObject:tour];
            }
        }
    }
    return tours;
}

@end

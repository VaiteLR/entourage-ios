//
//  OTEncounter.h
//  entourage
//
//  Created by Mathieu Hausherr on 11/10/14.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTTourTimelinePoint.h"

@interface OTEncounter : OTTourTimelinePoint

@property (strong, nonatomic) NSNumber *sid;
@property (nonatomic) double longitude;
@property (nonatomic) double latitude;
@property (strong, nonatomic) NSNumber *userId;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *streetPersonName;
@property (strong, nonatomic) NSString *message;

+ (OTEncounter *)encounterWithJSONDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryForWebservice;

@end

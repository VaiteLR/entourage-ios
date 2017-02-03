//
//  UIActivityViewController+sharing.m
//  entourage
//
//  Created by Guillaume Lagorce on 03/02/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "UIActivityViewController+sharing.h"
#import "OTEntourage.h"

@implementation UIActivityViewController (sharing)

+ (UIActivityViewController*)activityViewControllerForEntourage:(OTEntourage*)entourage {
    NSMutableArray *objectsToShare = [NSMutableArray array];
    if (entourage.title) {
        NSString *title = [NSString stringWithFormat:NSLocalizedString(@"sharing_text", nil), entourage.title];
        [objectsToShare addObject:title];
    }
    if (entourage.shareUrl) {
        [objectsToShare addObject:entourage.shareUrl];
    }
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];

    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];

    activityVC.excludedActivityTypes = excludeActivities;
    return activityVC;
}

@end

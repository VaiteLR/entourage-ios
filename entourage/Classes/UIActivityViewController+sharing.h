//
//  UIActivityViewController+sharing.h
//  entourage
//
//  Created by Guillaume Lagorce on 03/02/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OTEntourage;

@interface UIActivityViewController (sharing)

+ (UIActivityViewController*)activityViewControllerForEntourage:(OTEntourage*)entourage;

@end

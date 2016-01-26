//
//  UIView+entourage.m
//  entourage
//
//  Created by Ciprian Habuc on 20/01/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "UIView+entourage.h"

static const CGFloat kRadius = 5.f;

@implementation UIView (entourage)

- (void)setupRoundedCorners {
    self.layer.cornerRadius = kRadius;
}

@end
//
//  OTStateFactory.h
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItem.h"

typedef enum {
    FeedItemStateNone = -1,
    FeedItemStateOpen,
    FeedItemStateClosed,
    FeedItemStateFrozen,
    FeedItemStateQuit
} FeedItemState;

@protocol OTStateFactoryDelegate <NSObject>

- (void)closeWithSuccess:(void (^)())success;
- (void)freezeWithSuccess:(void (^)())success;
- (void)quitWithSuccess:(void (^)())success;
- (FeedItemState)getActionableState;
- (BOOL)canChangeState;

@end
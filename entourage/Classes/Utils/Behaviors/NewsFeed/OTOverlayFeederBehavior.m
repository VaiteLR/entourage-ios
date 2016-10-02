//
//  OTOverlayFeederBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/30/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTOverlayFeederBehavior.h"
#import "OTFeedItem.h"
#import "OTFeedItemFactory.h"
#import <objc/runtime.h>

static char kAssociatedObjectKey;

@implementation OTOverlayFeederBehavior

- (void)addOverlays:(NSArray *)items {
    [self addOverlaysToMap:items];
}

- (void)updateOverlays:(NSArray *)items {
    [self.mapView removeOverlays:self.mapView.overlays];
    [self addOverlaysToMap:items];
}

- (void)updateOverlayFor:(OTFeedItem *)item {
    id<MKOverlay> newOverlay = [[[OTFeedItemFactory createFor:item] getMapHandler] newsFeedOverlayData];
    if(!newOverlay)
        return;
    objc_setAssociatedObject(newOverlay, &kAssociatedObjectKey, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    id<MKOverlay> foundOverlay = nil;
    for(id<MKOverlay> overlay in self.mapView.overlays) {
        if([overlay isKindOfClass:[MKCircle class]])
            continue;
        id object = objc_getAssociatedObject(overlay, &kAssociatedObjectKey);
        if([object isEqual:item]) {
            foundOverlay = overlay;
            break;
        }
    }
    if(foundOverlay)
       [self.mapView removeOverlay:foundOverlay];
    [self.mapView addOverlay:newOverlay];
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    id object = objc_getAssociatedObject(overlay, &kAssociatedObjectKey);
    if([object isKindOfClass:[OTFeedItem class]]) {
        OTFeedItem *item = (OTFeedItem *)object;
        return [[[OTFeedItemFactory createFor:item] getMapHandler] newsFeedOverlayRenderer:overlay];
    }
    return nil;
}

#pragma mark - private methods

- (void)addOverlaysToMap:(NSArray *)items {
    for(OTFeedItem *item in items) {
        id<MKOverlay> overlay = [[[OTFeedItemFactory createFor:item] getMapHandler] newsFeedOverlayData];
        if(!overlay)
            return;
        objc_setAssociatedObject(overlay, &kAssociatedObjectKey, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if([overlay isKindOfClass:[MKCircle class]])
            [self.mapView insertOverlay:overlay atIndex:0];
        else if([overlay isKindOfClass:[MKPolyline class]])
            [self.mapView addOverlay:overlay];
    }
}

@end
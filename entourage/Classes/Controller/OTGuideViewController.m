//
//  OTGuideViewController.m
//  entourage
//
//  Created by Nicolas Telera on 09/09/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

// Controller
#import "OTGuideViewController.h"
#import "UIViewController+menu.h"
#import "OTCalloutViewController.h"

// View
#import "OTCustomAnnotation.h"
#import "JSBadgeView.h"

// Model
#import "OTPoi.h"

// Service
#import "OTPoiService.h"

// Framework
#import <MapKit/MapKit.h>
#import <MapKit/MKMapView.h>
#import <CoreLocation/CoreLocation.h>
#import <WYPopoverController/WYPopoverController.h>
#import "KPClusteringController.h"
#import "KPAnnotation.h"

// User
#import "NSUserDefaults+OT.h"

/********************************************************************************/
#pragma mark - OTMapViewController

@interface OTGuideViewController () <MKMapViewDelegate, OTCalloutViewControllerDelegate, CLLocationManagerDelegate>

// map

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;

// markers

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *pois;

@property (nonatomic, strong) WYPopoverController *popover;
@property (nonatomic, strong) KPClusteringController *clusteringController;

@property (nonatomic) BOOL isRegionSetted;
@property (nonatomic, strong) NSArray *tableData;

@end

@implementation OTGuideViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _locationManager = [[CLLocationManager alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    self.clusteringController = [[KPClusteringController alloc] initWithMapView:self.mapView];
    [self zoomToCurrentLocation:nil];
    [self createMenuButton];
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startLocationUpdates];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self refreshMap];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"currentUser"];
}

/**************************************************************************************************/
#pragma mark - Private methods

- (void)configureView {
    self.title = NSLocalizedString(@"guideviewcontroller_title", @"");
}

- (void)registerObserver {
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"currentUser"
                                               options:NSKeyValueObservingOptionNew
                                               context:nil];
}

- (void)refreshMap {
    [[OTPoiService new] poisAroundCoordinate:self.mapView.centerCoordinate
                                    distance:[self mapHeight]
                                     success:^(NSArray *categories, NSArray *pois)
                                     {
                                         [self.indicatorView setHidden:YES];
                                         
                                         self.categories = categories;
                                         self.pois = pois;
                                         
                                         [self feedMapViewWithPoiArray:pois];
                                     }
                                     failure:^(NSError *error) {
                                         [self registerObserver];
                                         [self.indicatorView setHidden:YES];
                                     }];
}

- (CLLocationDistance)mapHeight {
    MKMapPoint mpTopRight = MKMapPointMake(self.mapView.visibleMapRect.origin.x + self.mapView.visibleMapRect.size.height,
                                           self.mapView.visibleMapRect.origin.y);
    
    MKMapPoint mpBottomRight = MKMapPointMake(self.mapView.visibleMapRect.origin.x + self.mapView.visibleMapRect.size.width,
                                              self.mapView.visibleMapRect.origin.y + self.mapView.visibleMapRect.size.height);
    
    CLLocationDistance vDist = MKMetersBetweenMapPoints(mpTopRight, mpBottomRight) / 1000.f;
    
    return vDist;
}

- (void)feedMapViewWithPoiArray:(NSArray *)array {
    for (OTPoi *poi in array) {
        OTCustomAnnotation *pointAnnotation = [[OTCustomAnnotation alloc] initWithPoi:poi];
        [self.mapView addAnnotation:pointAnnotation];
    }
}

/********************************************************************************/
#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation> )annotation {
    MKAnnotationView *annotationView = nil;
    
    if ([annotation isKindOfClass:[OTCustomAnnotation class]]) {
        OTCustomAnnotation *customAnnotation = (OTCustomAnnotation *)annotation;
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:customAnnotation.annotationIdentifier];
        
        if (!annotationView) {
            annotationView = customAnnotation.annotationView;
        }
        annotationView.annotation = annotation;
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.clusteringController refresh:animated];
    [self refreshMap];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    [mapView deselectAnnotation:view.annotation animated:NO];
    
    if ([view.annotation isKindOfClass:[OTCustomAnnotation class]]) {
        // Start up our view controller from a Storyboard
        OTCalloutViewController *controller = (OTCalloutViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"OTCalloutViewController"];
        controller.delegate = self;
        
        UIView *popView = [controller view];
        
        popView.frame = CGRectOffset(view.frame, .0f, CGRectGetHeight(popView.frame) + 10000.f);
        
        [UIView animateWithDuration:.3f
                         animations: ^
         {
             popView.frame = CGRectOffset(popView.frame, .0f, -CGRectGetHeight(popView.frame));
         }];
        
        OTCustomAnnotation *annotation = [((MKAnnotationView *)view)annotation];
        
        [controller configureWithPoi:annotation.poi];
        
        self.popover = [[WYPopoverController alloc] initWithContentViewController:controller];
        [self.popover setTheme:[WYPopoverTheme themeForIOS7]];
        
        [self.popover presentPopoverFromRect:view.bounds
                                      inView:view
                    permittedArrowDirections:WYPopoverArrowDirectionNone
                                    animated:YES
                                     options:WYPopoverAnimationOptionFadeWithScale];
        [Flurry logEvent:@"Open_POI_From_Map" withParameters:@{ @"poi_id" : annotation.poi.sid }];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!self.isRegionSetted) {
        self.isRegionSetted = YES;
        [self zoomToCurrentLocation:nil];
    }
}

- (void)startLocationUpdates {
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    self.locationManager.distanceFilter = 5;
    
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *newLocation in locations) {
        
        NSDate *eventDate = newLocation.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20) {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
            [self.mapView setRegion:region animated:YES];
        }
    }
}

/********************************************************************************/
#pragma mark - OTCalloutViewControllerDelegate

- (void)dismissPopover {
    [self.popover dismissPopoverAnimated:YES];
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)zoomToCurrentLocation:(id)sender {
    float spanX = 0.0001;
    float spanY = 0.0001;
    MKCoordinateRegion region;
    
    region.center.latitude = self.mapView.userLocation.coordinate.latitude;
    region.center.longitude = self.mapView.userLocation.coordinate.longitude;
    
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [self.mapView setRegion:region animated:YES];
}

@end
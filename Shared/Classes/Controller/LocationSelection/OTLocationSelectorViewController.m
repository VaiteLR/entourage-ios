//
//  OTLocationSelectorViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 07/06/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTLocationSelectorViewController.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "MKMapView+entourage.h"
#import "OTLocationSearchTableViewController.h"
#import "UIStoryboard+entourage.h"
#import "OTEntourageEditorViewController.h"
#import "OTLocationManager.h"
#import "NSNotification+entourage.h"
#import "UIBarButtonItem+factory.h"
#import "OTMapView.h"

#define SEARCHBAR_FRAME CGRectMake(16, 80, [UIScreen mainScreen].bounds.size.width-32, 48)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

@interface OTLocationSelectorViewController () <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet OTMapView *mapView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong)  UISearchBar *searchBar;

@property (nonatomic, strong) UISearchController *resultSearchController;
@property (nonatomic, strong) OTLocationSearchTableViewController *locationSearchTable;

@end

@implementation OTLocationSelectorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = OTLocalizedString(@"myLocation").uppercaseString;
#if BETA
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
#endif
    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"validate")
                                                        withTarget:self
                                                         andAction:@selector(saveNewLocation)
                                                           andFont:@"SFUIText-Bold"
                                                           colored:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:menuButton];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LocationSelection" bundle:nil];
    self.locationSearchTable = (OTLocationSearchTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"OTLocationSearchTableViewController"];
    self.resultSearchController = [[UISearchController alloc] initWithSearchResultsController:self.locationSearchTable];
    self.resultSearchController.searchResultsUpdater = self.locationSearchTable;
    
    _searchBar = self.resultSearchController.searchBar;
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.placeholder = OTLocalizedString(@"searchLocationPlaceholder");
    if (@available(iOS 11.0, *)) {
        self.title = OTLocalizedString(@"myLocation").uppercaseString;
        self.navigationItem.searchController = self.resultSearchController;
    }
    else
    {
        self.navigationItem.titleView = self.resultSearchController.searchBar;
        for(UIView *subview in self.searchBar.subviews){
            UITextField *textField = subview.subviews[1];
            UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 13, 13)];
            textField.leftView = emptyView;
            UIImageView *leftImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search.png"]];
            [leftImage setFrame:CGRectMake(5, 0, 13, 13)];
            leftImage.contentMode = UIViewContentModeCenter;
            [textField.leftView addSubview: leftImage];
        }
    }
    self.resultSearchController.hidesNavigationBarDuringPresentation = NO;
    self.resultSearchController.dimsBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;
    self.locationSearchTable.mapView = self.mapView;
    self.locationSearchTable.pinDelegate = self;
    [self zoomToCurrentLocation:nil];
    UIBarButtonItem *cancelBtn = [UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil];
    [cancelBtn setTitle:OTLocalizedString(@"cancel")];
    [cancelBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor appOrangeColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"SFUItext-Bold" size:17], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zoomToCurrentLocation:) name:@kNotificationShowCurrentLocation object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)zoomToCurrentLocation:(id)sender {
    if(!self.selectedLocation)
        self.selectedLocation = [OTLocationManager sharedInstance].currentLocation;
    if (self.selectedLocation) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.selectedLocation.coordinate, MAPVIEW_REGION_SPAN_X_METERS, MAPVIEW_REGION_SPAN_Y_METERS );
        [self.mapView setRegion:region animated:NO];
        [self updateSelectedLocation:self.selectedLocation];
        [self.activityIndicator stopAnimating];
    }
}

#pragma mark - HandleMapSearch

- (void)dropPinZoomIn:(MKPlacemark *)placemark {
    self.selectedLocation = placemark.location;
    [self updateSelectedLocation:self.selectedLocation];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.mapView removeAnnotations:self.mapView.annotations];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, MAPVIEW_REGION_SPAN_X_METERS, MAPVIEW_REGION_SPAN_Y_METERS );
        [self.mapView setRegion:region];
        [self.activityIndicator stopAnimating];
    }];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView: (MKMapView *)mapView viewForAnnotation: (id)annotation {
    if([annotation isKindOfClass: [MKUserLocation class]])
        return nil;
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: @"myPin"];
    if (pin == nil)
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: @"myPin"];
    pin.annotation = annotation;
    pin.animatesDrop = NO;
    pin.draggable = NO;
    return pin;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    CLLocation *center = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    [self updateSelectedLocation:center];
}

#pragma mark - private methods

- (void)updateSelectedLocation:(CLLocation *) location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placemark = placemarks.firstObject;
        if (placemark.thoroughfare !=  nil) {
            [self.searchBar setText:placemark.thoroughfare];
        }
        else {
            [self.searchBar setText:placemark.locality];
        }
        if (error) {
            NSLog(@"error: %@", error.description);
        }
    }];
    self.selectedLocation = location;
}

- (void)saveNewLocation {
    [OTLogger logEvent:@"ValidateLocationChange"];
    if ([self.locationSelectionDelegate respondsToSelector:@selector(didSelectLocation:)]) {
        [self.locationSelectionDelegate didSelectLocation:self.selectedLocation];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end

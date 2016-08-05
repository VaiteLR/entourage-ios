//
//  OTPublicFeedItemViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPublicFeedItemViewController.h"
#import "OTSummaryProviderBehavior.h"
#import "OTMapAnnotationProviderBehavior.h"
#import "UIColor+entourage.h"
#import "OTFeedItemFactory.h"
#import "UIBarButtonItem+factory.h"
#import "OTFeedItemJoinRequestViewController.h"
#import "OTStatusBehavior.h"
#import "OTJoinBehavior.h"
#import "SVProgressHUD.h"

@interface OTPublicFeedItemViewController ()

@property (strong, nonatomic) IBOutlet OTSummaryProviderBehavior *summaryProvider;
@property (strong, nonatomic) IBOutlet OTMapAnnotationProviderBehavior *mapAnnotationProvider;
@property (strong, nonatomic) IBOutlet OTStatusBehavior *statusBehavior;
@property (strong, nonatomic) IBOutlet OTJoinBehavior *joinBehavior;

@end

@implementation OTPublicFeedItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.summaryProvider configureWith:self.feedItem];
    [self.mapAnnotationProvider configureWith:self.feedItem];
    [self.mapAnnotationProvider addStartPoint];
    [self.mapAnnotationProvider drawData];
    [self.statusBehavior initialize];
    [self.statusBehavior updateWith:self.feedItem];
    [self.joinBehavior configureWith:self.feedItem];

    self.title = [[[OTFeedItemFactory createFor:self.feedItem] getUI] navigationTitle].uppercaseString;
    if(FeedItemStateJoinNotRequested == [[[OTFeedItemFactory createFor:self.feedItem] getStateInfo] getState]) {
        UIBarButtonItem *joinButton = [UIBarButtonItem createWithImageNamed:@"share" withTarget:self andAction:@selector(joinFeedItem:)];
        [self.navigationItem setRightBarButtonItem:joinButton];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"JoinRequestSegue"])
        [self.joinBehavior prepareSegueForMessage:segue];
}

#pragma mark - private methods

- (IBAction)joinFeedItem:(id)sender {
    [self.joinBehavior joinFeedItem];
}

- (IBAction)updateStatusToPending {
    self.feedItem.joinStatus = JOIN_PENDING;
    [self.statusBehavior updateWith:self.feedItem];
    [self.navigationItem setRightBarButtonItem:nil];
}

@end

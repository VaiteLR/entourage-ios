//
//  OTPublicFeedItemViewController.m
//  entourage
//
//  Created by sergiu buceac on 8/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTPublicFeedItemViewController.h"
#import "OTSummaryProviderBehavior.h"
#import "UIColor+entourage.h"
#import "OTFeedItemFactory.h"
#import "UIBarButtonItem+factory.h"
#import "OTFeedItemJoinMessageController.h"
#import "OTStatusBehavior.h"
#import "OTJoinBehavior.h"
#import "SVProgressHUD.h"
#import "OTUserProfileBehavior.h"
#import "OTPublicInfoDataSource.h"
#import "OTTableDataSourceBehavior.h"
#import "OTStatusChangedBehavior.h"

@interface OTPublicFeedItemViewController ()

@property (strong, nonatomic) IBOutlet OTSummaryProviderBehavior *summaryProvider;
@property (strong, nonatomic) IBOutlet OTStatusBehavior *statusBehavior;
@property (strong, nonatomic) IBOutlet OTJoinBehavior *joinBehavior;
@property (strong, nonatomic) IBOutlet OTUserProfileBehavior *userProfileBehavior;
@property (strong, nonatomic) IBOutlet OTPublicInfoDataSource *dataSource;
@property (nonatomic, weak) IBOutlet OTTableDataSourceBehavior *tableDataSource;
@property (strong, nonatomic) IBOutlet OTStatusChangedBehavior *statusChangedBehavior;

@end

@implementation OTPublicFeedItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableDataSource initialize];
    [self.statusBehavior initialize];
    [self.statusChangedBehavior configureWith:self.feedItem];
    [self.statusBehavior updateWith:self.feedItem];
    self.dataSource.tableView.rowHeight = UITableViewAutomaticDimension;
    self.dataSource.tableView.estimatedRowHeight = 1000;

    self.title = [[[OTFeedItemFactory createFor:self.feedItem] getUI] navigationTitle].uppercaseString;
    UIBarButtonItem *moreButton = [UIBarButtonItem createWithImageNamed:@"share" withTarget:self.statusChangedBehavior andAction:@selector(startChangeStatus)];
    [self.navigationItem setRightBarButtonItem:moreButton];
    [self.dataSource loadDataFor:self.feedItem];
}

- (void)viewDidLayoutSubviews {
    [self.tableDataSource refresh];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
}

- (IBAction)showUserProfile:(id)sender {
    [Flurry logEvent:@"UserProfileClick"];
    [self.userProfileBehavior showProfile:self.feedItem.author.uID];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.joinBehavior prepareSegueForMessage:segue])
        return;
    if([self.userProfileBehavior prepareSegueForUserProfile:segue])
        return;
    if([self.statusChangedBehavior prepareSegueForNextStatus:segue])
        return;
}

#pragma mark - private methods

- (IBAction)joinFeedItem:(id)sender {
    [Flurry logEvent:@"AskJoinFromPublicPage"];
    [self.joinBehavior join:self.feedItem];
}

- (IBAction)updateStatusToPending {
    self.feedItem.joinStatus = JOIN_PENDING;
    [self.statusBehavior updateWith:self.feedItem];
}

@end

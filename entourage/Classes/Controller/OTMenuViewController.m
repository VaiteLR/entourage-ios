//
//  OTMenuViewController.m
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTAppDelegate.h"
#import "OTMenuViewController.h"

// Controller
#import "SWRevealViewController.h"
#import "OTLoginViewController.h"
#import "UIViewController+menu.h"
#import "OTSettingsViewController.h"

#import "NSUserDefaults+OT.h"


// Model
#import "OTMenuItem.h"
#import "OTUser.h"

// View
#import "OTMenuTableViewCell.h"
#import "SVProgressHUD.h"

// Utils
#import "UIButton+AFNetworking.h"
#import "UIButton+entourage.h"
#import "NSUserDefaults+OT.h"
#import "NSBundle+entourage.h"


/* MenuItem identifiers */
NSString *const OTMenuViewControllerSegueMenuMapIdentifier = @"segueMenuIdentifierForMap";
NSString *const OTMenuViewControllerSegueMenuGuideIdentifier = @"segueMenuIdentifierForGuide";
NSString *const OTMenuViewControllerSegueMenuProfileIdentifier = @"segueMenuIdentifierForProfile";
NSString *const OTMenuViewControllerSegueMenuSettingsIdentifier = @"segueMenuIdentifierForSettings";
NSString *const OTMenuViewControllerSegueMenuDisconnectIdentifier = @"segueMenuDisconnectIdentifier";
NSString *const OTMenuViewControllerSegueMenuAboutIdentifier = @"segueMenuIdentifierForAbout";

@interface OTMenuViewController () <UITableViewDataSource, UITableViewDelegate>

/**************************************************************************************************/
#pragma mark - Getters and Setters

// UI
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (nonatomic, weak) IBOutlet UILabel *versionLabel;

// Data
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSMutableDictionary *controllersDictionary;
@property (nonatomic, strong) OTUser *currentUser;

@end

@implementation OTMenuViewController

/**************************************************************************************************/
#pragma mark - View LifeCycle

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.versionLabel.text = [NSBundle currentVersion];
    
    self.currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    self.nameLabel.text = [self.currentUser displayName];


	self.menuItems = [OTMenuViewController createMenuItems];
	self.controllersDictionary = [NSMutableDictionary dictionary];
	[self configureControllersDictionary];
    
    self.title = @"MON COMPTE";
    [self createBackFrontMenuButton];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self.profileButton setupAsProfilePictureFromUrl:self.currentUser.avatarURL withPlaceholder:@"user"];
    
}

/**************************************************************************************************/
#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return (section == 0) ? 30.f : 1.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? self.menuItems.count - 1 : 1 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellID = (indexPath.section == 0) ?   OTMenuTableViewCellIdentifier :
                                                    OTMenuLogoutTableViewCellIdentifier;
    OTMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	OTMenuItem *menuItem = [self menuItemsAtIndexPath:indexPath];
    if (menuItem.iconName != nil)
        cell.itemIcon.image = [UIImage imageNamed:menuItem.iconName];
    cell.itemLabel.text = menuItem.title;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.section == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginFailureNotification object:self];
	}
	else {
		OTMenuItem *menuItem = [self menuItemsAtIndexPath:indexPath];
		[self openControllerWithSegueIdentifier:menuItem.segueIdentifier];

		[Flurry logEvent:@"Open_Screen_From_Menu" withParameters:@{ @"screen" : menuItem.segueIdentifier }];
	}
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)showProfile {
    //[self openControllerWithSegueIdentifier:@"OTUserProfile"];
    SWRevealViewController *revealViewController = self.revealViewController;
    [revealViewController revealToggle:self];
    [self performSegueWithIdentifier:@"segueMenuIdentifierForProfile" sender:nil];
    
}

/**
 * Method which opens the controller according to segueIdentifier.
 * This method has a particuler implementation.
 * - if the controller is not instanciated, we load it by the segue in Main.Storyboard
 * - if the controller is instanciated and isn't the current frontViewController, we push the new controller
 * - if the controller is instanciated and is the current frontViewController, we do only a revealToggle in order to avoid the effect of disappearance and  appearance
 *
 * @param segueIdentifier
 * The identifier of a segue
 */
- (void)openControllerWithSegueIdentifier:(NSString *)segueIdentifier {
	UIViewController *nextViewController = [self.controllersDictionary objectForKey:segueIdentifier];

	if (nextViewController) {
		SWRevealViewController *revealViewController = self.revealViewController;
		if (nextViewController != self.revealViewController.frontViewController) {
			[revealViewController pushFrontViewController:nextViewController animated:YES];
		}
		else {
			[revealViewController revealToggle:self];
		}
	}
	else {
		[self performSegueWithIdentifier:segueIdentifier sender:self];
	}
}

/**************************************************************************************************/
#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (![self.controllersDictionary objectForKey:segue.identifier] && [segue.identifier isEqualToString:@"OTUserProfile"]) {
        [self.controllersDictionary setObject:segue.destinationViewController forKey:segue.identifier];
    }
}

/**************************************************************************************************/
#pragma mark - Private methods

/**
 * Method which configure controllersDictionary with the first controller displayed by Main.storyboard.
 * According to the storyboard, this first controller is the Map
 * This method should be called in viewDidLoad
 *
 * @see OTMenuViewController - viewDidLoad
 */
- (void)configureControllersDictionary {
	UIViewController *frontViewController = self.revealViewController.frontViewController;

	if (frontViewController) {
		[self.controllersDictionary setObject:frontViewController
		                               forKey:OTMenuViewControllerSegueMenuMapIdentifier];
	}
}

/**
 * Method which creates all MenuItems in expected order for Menu
 *
 * @return NSArray<OTMenuItem>
 * All expected MenuItems
 */
+ (NSArray *)createMenuItems {
	NSMutableArray *menuItems = [NSMutableArray array];
    
    

    // Map
    OTMenuItem *itemMap = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_map_title", @"")
                                                   iconName: @"guide"
                                            segueIdentifier:OTMenuViewControllerSegueMenuMapIdentifier];
    [menuItems addObject:itemMap];
    
//    OTMenuItem *itemAmis = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_amis", @"")
//                                                    iconName: @"friends"
//                                             segueIdentifier:OTMenuViewControllerSegueMenuMapIdentifier];
//    [menuItems addObject:itemAmis];


    OTMenuItem *itemGuide = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_guide", @"")
                                                     iconName: @"guide"
                                              segueIdentifier:OTMenuViewControllerSegueMenuGuideIdentifier];
    [menuItems addObject:itemGuide];
    
    
    OTMenuItem *itemParam = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_param", @"")
                                                     iconName: @"parameters"
                                              segueIdentifier:OTMenuViewControllerSegueMenuSettingsIdentifier];
    [menuItems addObject:itemParam];

    
    OTMenuItem *itemAbout = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_about", @"")
                                                     iconName: @"about"
                                              segueIdentifier:OTMenuViewControllerSegueMenuAboutIdentifier];
    [menuItems addObject:itemAbout];

    // Disconnect
    OTMenuItem *itemDisconnect = [[OTMenuItem alloc] initWithTitle:NSLocalizedString(@"menu_disconnect_title", @"")
                                                          iconName: nil
                                                   segueIdentifier:OTMenuViewControllerSegueMenuDisconnectIdentifier];
    [menuItems addObject:itemDisconnect];
    
	return menuItems;
}

/**
 * Method which returns MenuItem according an indexpath
 *
 * @param indexPath
 * The indexPath to find the corresponding MenuItem in MenuItems
 *
 * @return OTMenuItem
 * The MenuItem according the indexpath
 */
- (OTMenuItem *)menuItemsAtIndexPath:(NSIndexPath *)indexPath {
	OTMenuItem *menuItem = nil;

	if (indexPath && (indexPath.row < self.menuItems.count)) {
		menuItem = [self.menuItems objectAtIndex:indexPath.row];
	}
    if (indexPath.section == 1) {
        menuItem = [self.menuItems lastObject];
    }

	return menuItem;
}

@end

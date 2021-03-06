//
//  OTDeepLinkService.m
//  entourage
//
//  Created by sergiu buceac on 8/17/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTDeepLinkService.h"
#import "OTAppDelegate.h"
#import "OTActiveFeedItemViewController.h"
#import "OTSWRevealViewController.h"
#import "SVProgressHUD.h"
#import "OTFeedItemFactory.h"
#import "OTUserViewController.h"
#import "OTPublicFeedItemViewController.h"
#import "OTAPIConsts.h"
#import "NSUserDefaults+OT.h"
#import "OTLoginViewController.h"
#import "OTMainViewController.h"
#import "OTSelectAssociationViewController.h"
#import "OTEntourageEditorViewController.h"
#import "OTTutorialViewController.h"
#import "OTSafariService.h"

@interface OTDeepLinkService ()

@property (nonatomic, weak) NSURL *link;

@end

@implementation OTDeepLinkService

- (void)navigateTo:(NSNumber *)feedItemId withType:(NSString *)feedItemType {
    [SVProgressHUD show];
    [[[OTFeedItemFactory createForType:feedItemType andId:feedItemId] getStateInfo] loadWithSuccess:^(OTFeedItem *feedItem) {
        [SVProgressHUD dismiss];
        [self prepareControllers:feedItem];
    } error:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

- (void)navigateTo: (NSString *)feedItemId {
    [SVProgressHUD show];
    if(TOKEN) {
        [[[OTFeedItemFactory createForId:feedItemId] getStateInfo] loadWithSuccess2:^(OTFeedItem *feedItem) {
        [SVProgressHUD dismiss];
        [self prepareControllers:feedItem];
        } error:^(NSError *error) {
            [SVProgressHUD dismiss];
        }];
    }
    else {
        [self navigateToLogin];
        [SVProgressHUD dismiss];
    }
}

- (UIViewController *)getTopViewController {
    UIViewController *result = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([result isKindOfClass:[SWRevealViewController class]]) {
        SWRevealViewController *revealController = (SWRevealViewController*)result;
        result = revealController.frontViewController;
    }
    if([result isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController*)result;
        result = navController.topViewController;
    }
    return result;
}

- (void)showProfileFromAnywhereForUser:(NSNumber *)userId {
    UIStoryboard *userProfileStorybard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:nil];
    UINavigationController *rootUserProfileController = (UINavigationController *)[userProfileStorybard instantiateInitialViewController];
    OTUserViewController *userController = (OTUserViewController *)rootUserProfileController.topViewController;
    userController.userId = userId;
    [self showControllerFromAnywhere:rootUserProfileController];
}

- (void)navigateToLogin {
    UIStoryboard *introStorybard = [UIStoryboard storyboardWithName:@"Intro" bundle:nil];
    OTLoginViewController *loginController = [introStorybard instantiateViewControllerWithIdentifier:@"OTLoginViewControllerIdentifier"];
    UIViewController *currentController = [self getTopViewController];
    loginController.fromLink = self.link;
    [currentController showViewController:loginController sender:self];
}

- (void)handleDeepLink: (NSURL *)url {
    NSString *host = url.host;
    NSString *query = url.query;
    self.link = url;
    if(!TOKEN) {
        [self navigateToLogin];
    } else {
        [self handleDeepLinkWithKey:host pathComponents:url.pathComponents andQuery:query];
    }
}

- (void)handleUniversalLink:(NSURL *)url {
    if (url.pathComponents == nil || url.pathComponents.count < 2) return;
    NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:url.pathComponents];
    // remove the leading '/'
    [pathComponents removeObjectAtIndex:0];
    // handle the 'entourages/<extra>'
    NSString *key = [pathComponents objectAtIndex:0];
    if ([key isEqualToString:@"entourages"]) {
        [self handleDeepLinkWithKey:key pathComponents:pathComponents andQuery:nil];
    }
    else if ([key isEqualToString:@"deeplink"]) {
        // handle the 'deeplink/<key>/<extra>?<query>'
        // remove the 'deeplink'
        [pathComponents removeObjectAtIndex:0];
        // handle the deep link
        key = [pathComponents objectAtIndex:0];
        [self handleDeepLinkWithKey:key pathComponents:pathComponents andQuery:url.query];
    }
}

- (void)handleDeepLinkWithKey:(NSString *)key pathComponents:(NSArray *)pathComponents andQuery:(NSString *)query {
    if ([key isEqualToString:@"feed"]) {
        OTMainViewController *mainViewController = [self popToMainViewController];
        [mainViewController leaveGuide];
        //            UIStoryboard *mainStorybard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //            OTMainViewController *mainController = (OTMainViewController *)[mainStorybard instantiateInitialViewController];
        //            [self updateAppWindow:mainController];
        // "feed/filters"
        if (pathComponents != nil && pathComponents.count >= 2) {
            if ([pathComponents[1] isEqualToString:@"filters"]) {
                [mainViewController showFilters];
            }
        }
    } else if ([key isEqualToString:@"badge"]) {
        OTSelectAssociationViewController *selectAssociationController = (OTSelectAssociationViewController *)[self instatiateControllerWithStoryboardIdentifier:@"UserProfileEditor" andControllerIdentifier:@"SelectAssociation"];
        [self showController:selectAssociationController];
    } else if ([key isEqualToString:@"webview"]) {
        NSArray *elts = [query componentsSeparatedByString:@"="];
        NSURL *url = [NSURL URLWithString:elts[1]];
        [self openWithWebView:url];
    } else if ([key isEqualToString:@"profile"]) {
        [self showProfileFromAnywhereForUser:[[NSUserDefaults standardUserDefaults] currentUser].sid];
    } else if ([key isEqualToString:@"messages"]) {
        OTMainViewController *mainViewController = [self popToMainViewController];
        [mainViewController performSegueWithIdentifier:@"MyEntouragesSegue" sender:nil];
    } else if ([key isEqualToString:@"create-action"]) {
        OTMainViewController *mainViewController = [self popToMainViewController];
        [mainViewController performSegueWithIdentifier:@"EntourageEditorSegue" sender:nil];
    } else if ([key isEqualToString:@"entourage"] || [key isEqualToString:@"entourages"]) {
        if (pathComponents != nil && pathComponents.count >= 2) {
            [self navigateTo:pathComponents[1]];
        }
    } else if ([key isEqualToString:@"guide"]) {
        OTMainViewController *mainViewController = [self popToMainViewController];
        [mainViewController switchToGuide];
    }
    else if ([key isEqualToString:@"tutorial"]) {
        OTMainViewController *mainViewController = [self popToMainViewController];
        UIStoryboard *tutorialStoryboard = [UIStoryboard storyboardWithName:@"Tutorial" bundle:nil];
        UIViewController *tutorialController = [tutorialStoryboard instantiateInitialViewController];
        [mainViewController presentViewController:tutorialController animated:YES completion:nil];
    }
    else if([key isEqualToString:@"phone-settings"]) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        });
    }
}

- (void)openWithWebView: (NSURL *)url {
    [OTSafariService launchInAppBrowserWithUrl:url viewController:nil];
}

- (UIViewController *)instatiateControllerWithStoryboardIdentifier: (NSString *)storyboardId
                                           andControllerIdentifier: (NSString *)controllerId {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardId bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:controllerId];
    return controller;
}

- (void)showController: (UIViewController *)controller {
    OTSWRevealViewController *revealController = [self setupRevealController];
    UINavigationController *mainController = (UINavigationController *)revealController.frontViewController;
    [mainController setViewControllers:@[mainController.topViewController, controller]];
    [self updateAppWindow:revealController];
}

- (void)showControllerFromAnywhere:(UIViewController *)controller {
    UIViewController *currentController = [self getTopViewController];
    while(currentController.presentedViewController)
        currentController = currentController.presentedViewController;
    [currentController presentViewController:controller animated:YES completion:nil];
}

- (OTMainViewController *)popToMainViewController {
    UIViewController *result = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([result isKindOfClass:[SWRevealViewController class]]) {
        SWRevealViewController *revealController = (SWRevealViewController*)result;
        [revealController setFrontViewPosition:FrontViewPositionLeft];
        result = revealController.frontViewController;
    }
    if([result isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController*)result;
        [navController popToRootViewControllerAnimated:NO];
        if ([navController.childViewControllers count] > 0) {
            if ([navController.childViewControllers[0] isKindOfClass:[OTMainViewController class]]) {
                [navController.childViewControllers[0] dismissViewControllerAnimated:NO completion:nil];
                return navController.childViewControllers[0];
            }
        }
    }
    return nil;
}

- (void)prepareControllers:(OTFeedItem *)feedItem {
    if([[[OTFeedItemFactory createFor:feedItem] getStateInfo] isPublic]) {
        UIStoryboard *publicFeedItemStorybard = [UIStoryboard storyboardWithName:@"PublicFeedItem" bundle:nil];
        OTPublicFeedItemViewController *publicFeedItemController = (OTPublicFeedItemViewController *)[publicFeedItemStorybard instantiateInitialViewController];
        publicFeedItemController.feedItem = feedItem;
        [self showController:publicFeedItemController];
    }
    else {
        UIStoryboard *activeFeedItemStorybard = [UIStoryboard storyboardWithName:@"ActiveFeedItem" bundle:nil];
        OTActiveFeedItemViewController *activeFeedItemController = (OTActiveFeedItemViewController *)[activeFeedItemStorybard instantiateInitialViewController];
        activeFeedItemController.feedItem = feedItem;
        [self showController:activeFeedItemController];
    }
}

- (OTSWRevealViewController *)setupRevealController {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OTSWRevealViewController *revealController = [mainStoryboard instantiateInitialViewController];
    UIViewController *menuController = [mainStoryboard instantiateViewControllerWithIdentifier:@"MenuNavController"];
    UINavigationController *mainController = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainNavController"];
    revealController.frontViewController = mainController;
    revealController.rearViewController = menuController;
    return revealController;
}

- (void)updateAppWindow:(UIViewController *)revealController {
    OTAppDelegate *appDelegate = (OTAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    window.rootViewController = revealController;
    [window makeKeyAndVisible];
}

@end

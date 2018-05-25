//
//  OTUserViewController.m
//  entourage
//
//  Created by Nicolas Telera on 17/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import "OTUserViewController.h"
#import "OTConsts.h"

#import "UIViewController+menu.h"
#import "OTAuthService.h"
#import "NSUserDefaults+OT.h"
#import "NSString+Validators.h"
#import "UIColor+entourage.h"
#import "UIButton+entourage.h"
#import "UIBarButtonItem+factory.h"
#import "SVProgressHUD.h"
#import "UIButton+AFNetworking.h"
#import "OTTapViewBehavior.h"
#import "UIImageView+entourage.h"
#import "OTUserTableConfigurator.h"
#import "OTMailSenderBehavior.h"
#import "OTAssociationDetailsViewController.h"
#import "OTMembersCell.h"
#import "OTPrivateCircleCell.h"
#import "entourage-Swift.h"

typedef NS_ENUM(NSInteger) {
    SectionTypeSummary,
    SectionTypeAssociations,
    SectionTypeVerification,
    SectionTypeEntourages,
    SectionTypePrivateCircles
} SectionType;

@interface OTUserViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet OTTapViewBehavior *tapToEditBehavior;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSArray *associationRows;
@property (nonatomic, strong) OTUser *currentUser;
@property (nonatomic, weak) IBOutlet OTMailSenderBehavior *mailSender;

@end

@implementation OTUserViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = OTLocalizedString(@"profil").uppercaseString;
    [self setupCloseModalWithTintColor];
    
    self.currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    self.mailSender.successMessage = OTLocalizedString(@"user_reported");
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 1000;
    
    NSNumber *userId = self.userId;
    if (!userId) {
        userId = self.user.sid;
    }
    
    if ([OTAppConfiguration supportsProfileEditing]) {
        if (userId.intValue == self.currentUser.sid.intValue) {
            [self.tapToEditBehavior initialize];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.user != nil) {
        self.userId = self.user.sid;
        [self configureTableSource];
        
        if (self.user.sid.intValue == self.currentUser.sid.intValue) {
            self.currentUser = [NSUserDefaults standardUserDefaults].currentUser;
            self.user = self.currentUser;
            
            if ([OTAppConfiguration supportsProfileEditing]) {
                [self showEditButton];
            }
        }
        else {
            [self showReportButton];
        }
        [self.tableView reloadData];
    }
    else {
        [self loadUser];
    }
    
    if (![self.userId isEqualToNumber:self.currentUser.sid]) {
        [OTLogger logEvent:@"Screen09_1OtherUserProfileView"];
        [self showReportButton];
    }
    else {
        [OTLogger logEvent:@"Screen09_1MyProfileViewAsPublicView"];
    }
}

#pragma mark - Private

- (void)showEditButton {
    UIBarButtonItem *chatButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"modify")
                                                        withTarget:self
                                                         andAction:@selector(showEditView)
                                                           andFont:@"SFUIText-Bold"
                                                           colored:[[ApplicationTheme shared] backgroundThemeColor]];
    [self.navigationItem setRightBarButtonItem:chatButton];
}

- (void)showReportButton {
    UIBarButtonItem *reportButton = [UIBarButtonItem createWithImageNamed:@"flag" withTarget:self andAction:@selector(sendReportMail) changeTintColor:YES];
    [self.navigationItem setRightBarButtonItem:reportButton];
}

- (void)sendReportMail {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Popup"
                                                         bundle:nil];
    OTPopupViewController *popup = [storyboard instantiateInitialViewController];
    NSMutableAttributedString *firstString = [[NSMutableAttributedString alloc] initWithString: OTLocalizedString(@"report_user_title")];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString: OTLocalizedString(@"report_user_attributed_title")];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"SFUIText-Medium" size: 17]  range:NSMakeRange(0, attributedString.length)];
    [firstString appendAttributedString:attributedString];
    popup.labelString = firstString;
    popup.textFieldPlaceholder = OTLocalizedString(@"report_user_placeholder");
    popup.buttonTitle = OTLocalizedString(@"report_user_button");
    popup.reportedUserId = self.user.sid.stringValue;
    
    [self presentViewController:popup
                       animated:YES
                     completion:nil];
}

- (IBAction)showEditView {
    [OTLogger logEvent:@"EditPhoto"];
    [self performSegueWithIdentifier:@"EditProfileSegue" sender:self];
}

- (void)loadUser {
    if (self.userId != nil) {
        [SVProgressHUD show];
        [[OTAuthService new] getDetailsForUser:self.userId success:^(OTUser *user) {
            [SVProgressHUD dismiss];
            self.user = user;
            [self configureTableSource];
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"user_profile_error")];
        }];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.user == nil) {
        return 0;
    }
    
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch ([self.sections[section] intValue]) {
        case SectionTypeSummary:
            return 1;
        case SectionTypeVerification:
            return 3;
        case SectionTypeEntourages:
            return 1;
        case SectionTypeAssociations:
            return self.associationRows.count;
        case SectionTypePrivateCircles: {
            return self.user.privateCircles.count > 0 ? self.user.privateCircles.count + 1 : 0;
        }
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (section == 0) ? 0.0f : 15.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .5f;
}

#define CELLHEIGHT_SUMMARY 237.0f
#define CELLHEIGHT_TITLE    33.0f
#define CELLHEIGHT_ENTOURAGES  80.0f
#define CELLHEIGHT_DEFAULT  48.0f

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 15)];
    headerView.backgroundColor = [UIColor appPaleGreyColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID;
    switch ([self.sections[indexPath.section] intValue]) {
        case SectionTypeSummary: {
            cellID = @"SummaryProfileCell";
            break;
        }
        case SectionTypeVerification: {
            cellID = indexPath.row == 0 ? @"TitleProfileCell" : @"VerificationProfileCell";
            break;
        }
        case SectionTypeEntourages: {
            cellID = @"EntouragesProfileCell";
            break;
        }
        case SectionTypeAssociations: {
            cellID = indexPath.row == 0 ? @"TitleProfileCell" : @"AssociationProfileCell";
            break;
        }
        case SectionTypePrivateCircles: {
            cellID = indexPath.row == 0 ? @"TitleProfileCell" : @"OTPrivateCircleCell";
            break;
        }
        default:
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    switch ([self.sections[indexPath.section] intValue]) {
        case SectionTypeSummary: {
            [self setupSummaryProfileCell:cell];
            break;
        }
        case SectionTypeVerification: {
            if (indexPath.row == 0)
                [self setupTitleProfileCell:cell withTitle:OTLocalizedString(@"user_verified")];
            else if (indexPath.row == 1)
                [self setupVerificationProfileCell:cell withCheck:OTLocalizedString(@"user_email_address") andStatus:YES];
            else
                [self setupVerificationProfileCell:cell withCheck:OTLocalizedString(@"user_phone_number") andStatus:YES];
            break;
        }
        case SectionTypeEntourages: {
            [self setupEntouragesProfileCell:cell];
            break;
        }
        case SectionTypeAssociations: {
            switch ([self.associationRows[indexPath.row] intValue]) {
                case AssociationRowTypeTitle:
                    [self setupTitleProfileCell:cell withTitle:OTLocalizedString(@"organizations")];
                    break;
                case AssociationRowTypeOrganisation:
                    [self setupAssociationProfileCell:cell
                                 withAssociationTitle:self.user.organization.name
                                andAssociationLogoUrl:self.user.organization.logoUrl];
                    cell.userInteractionEnabled = NO;
                    break;
                case AssociationRowTypePartner:
                    [self setupAssociationPartnerCell:cell withPartner:self.user.partner];
                default:
                    break;
            }
            break;
        }
        case SectionTypePrivateCircles: {
            if (indexPath.row == 0) {
                [self setupTitleProfileCell:cell withTitle:[OTAppAppearance userPrivateCirclesSectionTitle:self.user]];
                break;
            } else {
                OTUserMembershipListItem *privateCircleItem = [self.user.privateCircles objectAtIndex:indexPath.row - 1];
                OTPrivateCircleCell *privateCircleCell = (OTPrivateCircleCell*)cell;
                [privateCircleCell configureWithItem:privateCircleItem];
                return privateCircleCell;
            };
        }
    }
    return cell;
}

#define SUMMARY_AVATAR 1
#define SUMMARY_AVATAR_SHADOW 10

#define SUMMARY_RIGHT_CONTAINER_TAG 11
#define SUMMARY_RIGHT_TAG 12
#define SUMMARY_LEFT_CONTAINER_TAG 13
#define SUMMARY_LEFT_TAG 14

#define SUMMARY_NAME 2
#define SUMMARY_DESCRIPTION 3
#define SUMMARY_TITLE 6
#define HEADER_BG_VIEW 20

#define VERIFICATION_LABEL 1
#define VERIFICATION_STATUS 2

#define NOENTOURAGES 1
#define NOENTOURAGESTITLE 2

#define ASSOCIATION_TITLE 1
#define ASSOCIATION_IMAGE 2
#define ASSOCIATION_SUPPORT_TYPE 3

- (void)setupSummaryProfileCell:(UITableViewCell *)cell {
    UIImageView *imgAssociation = [cell viewWithTag:99];
    imgAssociation.hidden = self.user.partner == nil;
    [imgAssociation setupFromUrl:self.user.partner.smallLogoUrl withPlaceholder:@"badgeDefault"];
    
    UIView *avatarShadow = [cell viewWithTag:SUMMARY_AVATAR_SHADOW];
    [avatarShadow.layer setShadowColor:[UIColor blackColor].CGColor];
    [avatarShadow.layer setShadowOpacity:0.5];
    [avatarShadow.layer setShadowRadius:4.0];
    [avatarShadow.layer setShadowOffset:CGSizeMake(0.0, 1.0)];
    UIButton *avatarButton = [cell viewWithTag:SUMMARY_AVATAR];
    avatarButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [avatarButton setupAsProfilePictureFromUrl:self.user.avatarURL withPlaceholder:@"user"];
    
    UILabel *nameLabel = [cell viewWithTag:SUMMARY_NAME];
    nameLabel.text = self.user.displayName;
    
    UILabel *aboutMeLabel = [cell viewWithTag:SUMMARY_DESCRIPTION];
    aboutMeLabel.text = self.user.about;
    
    UIView *rightTagContainer = [cell viewWithTag:SUMMARY_RIGHT_CONTAINER_TAG];
    rightTagContainer.backgroundColor = [OTAppAppearance rightTagColor:self.user];
    
    UIView *leftTagContainer = [cell viewWithTag:SUMMARY_LEFT_CONTAINER_TAG];
    leftTagContainer.backgroundColor = [OTAppAppearance leftTagColor:self.user];
    
    UILabel *rightTagLabel = [cell viewWithTag:SUMMARY_RIGHT_TAG];
    rightTagLabel.text = self.user.rightTag;
    
    UILabel *leftTagLabel = [cell viewWithTag:SUMMARY_LEFT_TAG];
    leftTagLabel.text = self.user.leftTag;
    
    UIView *headerBgView = [cell viewWithTag:HEADER_BG_VIEW];
    headerBgView.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
}

- (void)setupTitleProfileCell:(UITableViewCell *)cell withTitle:(NSString *)title {
    UILabel *titleLabel = [cell viewWithTag:SUMMARY_TITLE];
    titleLabel.text = title;
    cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
}

- (void)setupVerificationProfileCell:(UITableViewCell *)cell
                           withCheck:(NSString *)checkString
                           andStatus:(BOOL)isChecked
{
    UILabel *checkLabel = [cell viewWithTag:VERIFICATION_LABEL];
    checkLabel.text = checkString;
    UIButton *statusButton = [cell viewWithTag:VERIFICATION_STATUS];
    NSString *statusImage = isChecked ? @"verified" : @"notVerified";
    [statusButton setImage:[UIImage imageNamed: statusImage] forState:UIControlStateNormal];
}

- (void)setupEntouragesProfileCell:(UITableViewCell *)cell {
    UILabel *noEntouragesLabel = [cell viewWithTag:NOENTOURAGES];
    UILabel *noEntouragesTitleLabel = [cell viewWithTag:NOENTOURAGESTITLE];
    noEntouragesTitleLabel.text = [OTAppAppearance numberOfUserActionsTitle];
    noEntouragesLabel.text = [OTAppAppearance numberOfUserActionsValueTitle:self.user];
}

- (void)setupAssociationProfileCell:(UITableViewCell *)cell
               withAssociationTitle:(NSString *)title
              andAssociationLogoUrl:(NSString *)imageURL
{
    UIButton *titleBtn = [cell viewWithTag:ASSOCIATION_TITLE];
    [titleBtn setTitle:title forState:UIControlStateNormal];
    UIButton *associationImageButton = [cell viewWithTag:ASSOCIATION_IMAGE];
    [associationImageButton setImage:nil forState:UIControlStateNormal];
    if (associationImageButton != nil && [imageURL class] != [NSNull class] && imageURL.length > 0)
        [associationImageButton setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:imageURL]];
    UILabel *lblSupportType = [cell viewWithTag:ASSOCIATION_SUPPORT_TYPE];
    lblSupportType.text = OTLocalizedString(@"marauder");
}

- (void)setupAssociationPartnerCell:(UITableViewCell *)cell
                        withPartner:(OTAssociation *)partner {
    UIButton *titleBtn = [cell viewWithTag:ASSOCIATION_TITLE];
    [titleBtn setTitle:partner.name forState:UIControlStateNormal];
    [titleBtn addTarget:self action:@selector(showPartnerDetails) forControlEvents:UIControlEventTouchUpInside];
    UIButton *associationImageButton = [cell viewWithTag:ASSOCIATION_IMAGE];
    [associationImageButton setImage:nil forState:UIControlStateNormal];
    [associationImageButton addTarget:self action:@selector(showPartnerDetails) forControlEvents:UIControlEventTouchUpInside];
    NSString *imageUrl = partner.largeLogoUrl;
    if (associationImageButton != nil && [imageUrl class] != [NSNull class] && imageUrl.length > 0)
        [associationImageButton setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:imageUrl]];
    UILabel *lblSupportType = [cell viewWithTag:ASSOCIATION_SUPPORT_TYPE];
    lblSupportType.text = OTLocalizedString(@"sympathizant");
}

- (void)configureTableSource {
    [self configureSections];
    self.associationRows = [OTUserTableConfigurator getAssociationRowsForUser:self.user];
}

- (void)configureSections {
    NSMutableArray *mSections = [NSMutableArray arrayWithObject:@(SectionTypeSummary)];
    
    if ([OTAppConfiguration shouldShowNumberOfUserAssociationsSection:self.user]) {
        [mSections addObject:@(SectionTypeAssociations)];
    }
    
    [mSections addObject:@(SectionTypeVerification)];
    
    if ([OTAppConfiguration shouldShowNumberOfUserPrivateCirclesSection:self.user]) {
        [mSections addObject:@(SectionTypePrivateCircles)];
    }
    
    if ([OTAppConfiguration shouldShowNumberOfUserActionsSection:self.user]) {
        [mSections addObject:@(SectionTypeEntourages)];
    }
    
    self.sections = mSections;
}

- (void)showPartnerDetails {
    if (self.user.sid.intValue == self.currentUser.sid.intValue) {
        [self performSegueWithIdentifier:@"EditProfileSegue" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"AssociationDetails" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"AssociationDetails"]) {
        UINavigationController *controller = (UINavigationController *)segue.destinationViewController;
        OTAssociationDetailsViewController *associationController = (OTAssociationDetailsViewController *)controller.topViewController;
        associationController.association = self.user.partner;
    }
}

@end

//
//  OTEditEntourageTitleViewController.m
//  entourage
//
//  Created by sergiu.buceac on 18/05/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTEditEntourageTitleViewController.h"
#import "OTTextWithCount.h"
#import "UIColor+entourage.h"
#import "UIBarButtonItem+factory.h"
#import "OTConsts.h"

@interface OTEditEntourageTitleViewController ()

@property (nonatomic, weak) IBOutlet OTTextWithCount *txtTitle;

@end

@implementation OTEditEntourageTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"validate") withTarget:self andAction:@selector(doneEdit) colored:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:menuButton];
    self.txtTitle.maxLength = 100;
    self.txtTitle.textView.text = self.currentTitle;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if(self.currentTitle)
        [self.txtTitle updateAfterSpeech];
}

- (void)doneEdit {
    [self.delegate titleEdited:self.txtTitle.textView.text];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

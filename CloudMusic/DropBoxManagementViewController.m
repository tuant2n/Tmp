//
//  DropBoxManagementViewController.m
//  CloudMusic
//
//  Created by TuanTN on 4/7/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "DropBoxManagementViewController.h"
#import <DropboxSDK/DropboxSDK.h>

#import "Utils.h"

@interface DropBoxManagementViewController ()

@property (nonatomic, strong) UIBarButtonItem *btnLogout, *btnLogin;

@end

@implementation DropBoxManagementViewController

- (UIBarButtonItem *)btnLogout
{
    if (!_btnLogout) {
        _btnLogout = [[UIBarButtonItem alloc] initWithCustomView:[Utils createBarButtonWithTitle:@"Logout" font:[UIFont fontWithName:@"helveticaNeue" size:15.0] textColor:0xff0000 position:UIControlContentHorizontalAlignmentRight target:self action:@selector(logout)]];
    }
    return _btnLogout;
}

- (UIBarButtonItem *)btnLogin
{
    if (!_btnLogin) {
        _btnLogin = [[UIBarButtonItem alloc] initWithCustomView:[Utils createBarButtonWithTitle:@"Login" font:[UIFont fontWithName:@"helveticaNeue" size:15.0] textColor:0x007cf6 position:UIControlContentHorizontalAlignmentRight target:self action:@selector(login)]];
    }
    return _btnLogin;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:NOTIFICATION_LOGIN_DROPBOX object:nil];
}

- (void)loginSuccess:(NSNotification *)notification
{
    BOOL isSuccess = [notification.object boolValue];
    
    if (isSuccess) {
        [self configWhenLinked];
    }
    else {
        [self configWhenNotLinked];
    }
}

- (void)setupUI
{
    self.title = @"Dropbox";
    [Utils configNavigationController:self.navigationController];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    if ([[DBSession sharedSession] isLinked]) {
        [self configWhenLinked];
    }
    else {
        [self configWhenNotLinked];
    }
}

- (void)configWhenLinked
{
    self.navigationItem.rightBarButtonItem = self.btnLogout;
}

- (void)configWhenNotLinked
{
    self.navigationItem.rightBarButtonItem = self.btnLogin;
}

- (void)login
{
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
}

- (void)logout
{
    if ([[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] unlinkAll];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

//
//  FilesViewController.m
//  CloudMusic
//
//  Created by TuanTN on 3/6/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "FilesViewController.h"
#import <DropboxSDK/DropboxSDK.h>

#import "Utils.h"
#import "GlobalParameter.h"

#import "DropBoxManagementViewController.h"

#import "PCSEQVisualizer.h"

@interface FilesViewController ()

@property (nonatomic, strong) PCSEQVisualizer *musicEq;
@property (nonatomic, strong) UIBarButtonItem *barMusicEq;
@property (nonatomic, strong) UIBarButtonItem *barBtnAddFile;

@property (nonatomic, weak) IBOutlet UIView *vNotFound;
@property (nonatomic, weak) IBOutlet UIButton *btnConnectDropbox;

@property (nonatomic, weak) IBOutlet UITableView *tblList;

@end

@implementation FilesViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:NOTIFICATION_LOGIN_DROPBOX object:nil];
}

- (void)setupUI
{
    self.title = @"Files";
    self.navigationItem.rightBarButtonItem = self.barMusicEq;
    self.navigationItem.leftBarButtonItem = self.barBtnAddFile;
    [Utils configNavigationController:self.navigationController];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    [self.btnConnectDropbox setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnConnectDropbox setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.btnConnectDropbox setBackgroundImage:[Utils imageWithColor:0x017ee6] forState:UIControlStateNormal];
    self.btnConnectDropbox.layer.cornerRadius = 5.0;
    self.btnConnectDropbox.clipsToBounds = YES;
    
    [self setupTableView];
    [self setShowNotFoundView:YES];
}

- (void)setupTableView
{
    [self.tblList setTableFooterView:[UIView new]];
}

- (void)setupData
{
    
}

#pragma mark - Utils

- (void)setShowNotFoundView:(BOOL)isShow
{
    if (isShow) {
        self.vNotFound.hidden = NO;
        [self.view bringSubviewToFront:self.vNotFound];
    }
    else {
        self.vNotFound.hidden = YES;
        [self.view sendSubviewToBack:self.vNotFound];
    }
}

- (PCSEQVisualizer *)musicEq
{
    if (!_musicEq) {
        _musicEq = [[PCSEQVisualizer alloc] initWithNumberOfBars:3 barWidth:2 height:18.0 color:0x006bd5];
    }
    return _musicEq;
}

- (UIBarButtonItem *)barMusicEq
{
    if (!_barMusicEq)
    {
        _barMusicEq = [[UIBarButtonItem alloc] initWithCustomView:[Utils buttonMusicEqualizeqHolderWith:self.musicEq target:self action:@selector(openPlayer:)]];
    }
    return _barMusicEq;
}

- (UIBarButtonItem *)barBtnAddFile
{
    if (!_barBtnAddFile) {
        _barBtnAddFile = [[UIBarButtonItem alloc] initWithCustomView:[Utils createBarButton:@"icn-add-music-normal.png" position:UIControlContentHorizontalAlignmentLeft target:self selector:@selector(touchConnectDropbox:)]];
    }
    return _barBtnAddFile;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.musicEq stopEq:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[GlobalParameter sharedInstance] isPlay]) {
        [self.musicEq startEq];
    }
    else {
        [self.musicEq stopEq:NO];
    }
}

- (void)openPlayer:(id)sender
{
    [self.musicEq startEq];
    [[GlobalParameter sharedInstance] startPlay];
}

#pragma mark - DropBox Connect

- (IBAction)touchConnectDropbox:(id)sender
{
    [self connectToDropbox];
}

- (void)connectToDropbox
{
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
    else {
        [self gotoDropbox];
    }
}

- (void)loginSuccess:(NSNotification *)notification
{
    [self gotoDropbox];
}

- (void)gotoDropbox
{
    DropBoxManagementViewController *vc = [[DropBoxManagementViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

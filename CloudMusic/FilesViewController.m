//
//  FilesViewController.m
//  CloudMusic
//
//  Created by TuanTN on 3/6/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "FilesViewController.h"

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

@end

@implementation FilesViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI
{
    self.title = @"Files";
    self.navigationItem.rightBarButtonItem = self.barMusicEq;
    self.navigationItem.leftBarButtonItem = self.barBtnAddFile;
    [Utils configNavigationController:self.navigationController];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    [self setupNotFound];
}

- (void)setupNotFound
{
    self.vNotFound.backgroundColor = [Utils colorWithRGBHex:0xf7f7f7];
    
    UIColor *color = [Utils colorWithRGBHex:0x0070df];
    [self.btnConnectDropbox setTitleColor:color forState:UIControlStateNormal];
    
    [self.btnConnectDropbox setBackgroundImage:[Utils imageWithColor:0xffffff] forState:UIControlStateNormal];
    [self.btnConnectDropbox setBackgroundImage:[Utils imageWithColor:0xd0d0d0] forState:UIControlStateHighlighted];
    
    self.btnConnectDropbox.layer.cornerRadius = 10.0;
    self.btnConnectDropbox.layer.borderColor = color.CGColor;
    self.btnConnectDropbox.layer.borderWidth = 1.5;
    self.btnConnectDropbox.alpha = 0.85;
    self.btnConnectDropbox.clipsToBounds = YES;
}

- (IBAction)touchConnectDropbox:(id)sender
{
    [self gotoDropbox];
}

- (void)setupData
{
    
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
        _barBtnAddFile = [[UIBarButtonItem alloc] initWithCustomView:[Utils createBarButton:@"icn-add-music-normal.png" position:UIControlContentHorizontalAlignmentLeft target:self selector:@selector(addFile)]];
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

- (void)addFile
{
    [self gotoDropbox];
}

- (void)gotoDropbox
{
    DropBoxManagementViewController *vc = [[DropBoxManagementViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

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

#import "PCSEQVisualizer.h"

@interface FilesViewController ()

@property (nonatomic, strong) PCSEQVisualizer *musicEq;
@property (nonatomic, strong) UIBarButtonItem *barMusicEq;
@property (nonatomic, strong) UIBarButtonItem *barBtnAddFile;

@end

@implementation FilesViewController

- (PCSEQVisualizer *)musicEq
{
    if (!_musicEq) {
        _musicEq = [[PCSEQVisualizer alloc] initWithNumberOfBars:3 barWidth:2 height:18.0 color:0x006bd5];
        _musicEq.userInteractionEnabled = NO;
    }
    return _musicEq;
}

- (UIBarButtonItem *)barMusicEq
{
    if (!_barMusicEq)
    {
        UIButton *btnEqHolder = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnEqHolder setFrame:CGRectMake(0.0, 0.0, 35.0, 35.0)];
        btnEqHolder.backgroundColor = [UIColor clearColor];
        [btnEqHolder addTarget:self action:@selector(openPlayer:) forControlEvents:UIControlEventTouchUpInside];
        btnEqHolder.multipleTouchEnabled = NO;
        btnEqHolder.exclusiveTouch = YES;
        
        CGRect frame = self.musicEq.frame;
        frame.origin.x = (btnEqHolder.frame.size.width - frame.size.width);
        frame.origin.y = (btnEqHolder.frame.size.height - frame.size.height) / 2.0;
        self.musicEq.frame = frame;
        [btnEqHolder addSubview:self.musicEq];
        
        _barMusicEq = [[UIBarButtonItem alloc] initWithCustomView:btnEqHolder];
    }
    return _barMusicEq;
}

- (UIBarButtonItem *)barBtnAddFile
{
    if (!_barBtnAddFile) {
        UIButton *btnAddFile = [Utils createBarButton:@"icn-add-music-normal.png" position:UIControlContentHorizontalAlignmentLeft target:self selector:@selector(addFile)];
        _barBtnAddFile = [[UIBarButtonItem alloc] initWithCustomView:btnAddFile];
    }
    return _barBtnAddFile;
}

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
}

- (void)setupData
{
    
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
    [self.musicEq stopEq:YES];
    [[GlobalParameter sharedInstance] pausePlay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

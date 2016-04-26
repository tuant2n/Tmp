//
//  PlayerViewController.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/10/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "PlayerViewController.h"

#import "Utils.h"

#import "NBTouchAndHoldButton.h"

#define FARST_SEEK_TIME 1.0

static PlayerViewController *sharedInstance = nil;

@interface PlayerViewController ()
{
    BOOL isSeek;
}

@property (nonatomic, strong) UIButton *btnClose;

@property (nonatomic, weak) IBOutlet UIView *vPlayer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *vPlayerHeight;

@property (nonatomic, weak) IBOutlet UIView *vControlPlayer, *vInfoPlayer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *vControlPlayerWidth, *vInfoPlayerWidth;

@property (nonatomic, weak) IBOutlet UIButton *btnPlay, *btnPause;
@property (nonatomic, weak) IBOutlet NBTouchAndHoldButton *btnNext, *btnPrev;

@property (nonatomic, weak) IBOutlet UILabel *lblCurrent, *lblRemain;
@property (nonatomic, weak) IBOutlet UISlider *seekSlider;

@end

@implementation PlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (sharedInstance) {
        [NSException raise:@"Error" format:@"Tried to create more than one instance"];
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

+ (PlayerViewController *)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
    });
    return sharedInstance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [self configPlayerViewFrame];
}

#pragma mark - Action

- (void)farstFoward
{
    isSeek = YES;
    NSLog(@"farstFoward begin");
}

- (void)nextSong
{
    if (!isSeek) {
        NSLog(@"next song");
    }
    else {
        NSLog(@"farstFoward end");
    }
    isSeek = NO;
}

- (void)farstBackward
{
    isSeek = YES;
    NSLog(@"farstBackward begin");
}

- (void)prevSong
{
    if (!isSeek) {
        NSLog(@"prev song");
    }
    else {
        NSLog(@"farstBackward end");
    }
    isSeek = NO;
}

- (void)play
{
    
}

- (void)pause
{
    
}

#pragma mark - UI

- (void)setupUI
{
    self.title = @"1 of 1";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnClose];
    
    [self setupControlPlayer];
    [self setupSeekView];
}

- (UIButton *)btnClose
{
    if (!_btnClose) {
        _btnClose = [Utils createBarButton:@"btn_close_player" position:UIControlContentHorizontalAlignmentLeft target:self selector:@selector(closeView)];
    }
    return _btnClose;
}

- (void)configPlayerViewFrame
{
    if ([Utils isLandscapeDevice]) {
        [self.vPlayerHeight setConstant:90.0];
        [self.vInfoPlayerWidth setConstant:DEVICE_SIZE.height/2.0];
        [self.vControlPlayerWidth setConstant:DEVICE_SIZE.height/2.0];
    }
    else {
        [self.vPlayerHeight setConstant:180.0];
        [self.vInfoPlayerWidth setConstant:DEVICE_SIZE.width];
        [self.vControlPlayerWidth setConstant:DEVICE_SIZE.width];
    }
}

- (void)setupControlPlayer
{
    [self.btnNext addTarget:self action:@selector(farstFoward) forTouchAndHoldControlEventWithTimeInterval:FARST_SEEK_TIME];
    [self.btnNext addTarget:self action:@selector(nextSong) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnPrev addTarget:self action:@selector(farstBackward) forTouchAndHoldControlEventWithTimeInterval:FARST_SEEK_TIME];
    [self.btnPrev addTarget:self action:@selector(prevSong) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnPlay addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPause addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupSeekView
{
    [self.seekSlider setMinimumTrackImage:[[UIImage imageNamed:@"maxTrack"] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forState:UIControlStateNormal];
    [self.seekSlider setMaximumTrackImage:[[UIImage imageNamed:@"minTrack"] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forState:UIControlStateNormal];
    [self.seekSlider setThumbImage:[UIImage imageNamed:@"thumbTrack"] forState:UIControlStateNormal];
}

- (void)closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

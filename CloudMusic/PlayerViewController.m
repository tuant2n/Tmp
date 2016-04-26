//
//  PlayerViewController.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/10/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "PlayerViewController.h"

#import "Utils.h"
#import "CoreMusicPlayer.h"
#import "DataManagement.h"

#import "NBTouchAndHoldButton.h"

#define FARST_SEEK_TIME 1.0

static PlayerViewController *sharedInstance = nil;

@interface PlayerViewController () <CoreMusicPlayerDataSource,CoreMusicPlayerDelegate>
{
    BOOL isSeek;
    id mTimeObserver;
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

//
@property (nonatomic, strong) NSMutableArray *playlist;

@end

@implementation PlayerViewController

#pragma mark- Init

+ (PlayerViewController *)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
    });
    return sharedInstance;
}

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

#pragma mark - UI

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    CoreMusicPlayer *musicPlayer = [CoreMusicPlayer sharedInstance];
    musicPlayer.delegate = self;
    musicPlayer.datasource = self;
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [self configPlayerViewFrame];
}

#pragma mark - Player

- (NSMutableArray *)playlist
{
    if (!_playlist) {
        _playlist = [[NSMutableArray alloc] init];
    }
    return _playlist;
}

- (void)playWithPlaylist:(NSArray *)listSongs isShuffle:(BOOL)isShuffle
{
    [self.playlist removeAllObjects];
    [self.playlist addObjectsFromArray:listSongs];
    
    if (isShuffle) {
        [[CoreMusicPlayer sharedInstance] setPlayerShuffleMode:CoreMusicPlayerShuffleModeOn];
    }
    [[CoreMusicPlayer sharedInstance] setPlayerRepeatMode:CoreMusicPlayerRepeatModeOff];
}

- (void)playWithSong:(Item *)song
{
    // check if song is in playlist -> play song
}

- (void)playerDidFailed:(CoreMusicPlayerFailed)iStatus atIndex:(NSInteger)index
{
    switch (iStatus)
    {
        case CoreMusicPlayerFailedPlayer:
            break;
            
        case CoreMusicPlayerFailedCurrentItem:
            [[CoreMusicPlayer sharedInstance] playNext];
            break;
            
        default:
            break;
    }
}

- (void)playerReadyToPlay:(CoreMusicPlayerReadyToPlay)iStatus
{
    switch (iStatus)
    {
        case CoreMusicPlayerReadyToPlayPlayer:
        {
            if ( mTimeObserver == nil ) {
                mTimeObserver = [[CoreMusicPlayer sharedInstance] addPeriodicTimeObserverForInterval:CMTimeMake(100, 1000) queue:NULL usingBlock:^(CMTime time)
                                 {
                                     float totalSecond = CMTimeGetSeconds(time);
                                     int minute = (int)totalSecond / 60;
                                     int second = (int)totalSecond % 60;
                                     NSLog(@"%@",[NSString stringWithFormat:@"%02d:%02d", minute, second]);
                                 }];
            }
            
            break;
        }
            
            
        case CoreMusicPlayerReadyToPlayCurrentItem:
        {
            // It will be called when current PlayerItem is ready to play.
            
            // HysteriaPlayer will automatic play it, if you don't like this behavior,
            // You can pausePlayerForcibly:YES to stop it.
            break;
        }
            
        default:
            break;
    }
}

- (void)playerCurrentItemChanged:(AVPlayerItem *)item
{
    NSLog(@"current item changed");
}

- (void)playerCurrentItemPreloaded:(CMTime)time
{
    NSLog(@"current item pre-loaded time: %f", CMTimeGetSeconds(time));
}

- (void)playerDidReachEnd
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Player did reach end."
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil, nil];
    [alert show];
}

- (void)playerRateChanged
{
//    [self syncPlayPauseButtons];
    NSLog(@"player rate changed");
}

- (void)playerWillChangedAtIndex:(NSInteger)index
{
    NSLog(@"index: %li is about to play", index);
}

- (NSInteger)numberOfItems
{
    return self.playlist.count;
}

- (NSURL *)URLForItemAtIndex:(NSInteger)index preBuffer:(BOOL)preBuffer;
{
    Item *song = self.playlist[index];
    return song.sPlayableUrl;
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

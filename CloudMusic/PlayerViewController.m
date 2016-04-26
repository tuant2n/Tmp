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
#import "MarqueeLabel.h"

#define FARST_SEEK_TIME 1.0

static PlayerViewController *sharedInstance = nil;

@interface PlayerViewController () <CoreMusicPlayerDataSource,CoreMusicPlayerDelegate>
{
    BOOL isSeek, isPlaySingleSong;
    id mTimeObserver;
}

@property (nonatomic, strong) UIButton *btnClose;

@property (nonatomic, weak) IBOutlet UIView *vPlayer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *vPlayerHeight;

@property (nonatomic, weak) IBOutlet UIView *vControlPlayer, *vInfoPlayer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *vControlPlayerWidth, *vInfoPlayerWidth;

@property (nonatomic, weak) IBOutlet MarqueeLabel *lblSongName, *lblSongDesc;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingView;
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

- (void)setDelegate
{
    CoreMusicPlayer *musicPlayer = [CoreMusicPlayer sharedInstance];
    
    if (musicPlayer.delegate != self) {
        musicPlayer.delegate = self;
    }
    
    if (musicPlayer.datasource != self) {
        musicPlayer.datasource = self;
    }
}

- (void)playWithPlaylist:(NSArray *)listSongs isShuffle:(BOOL)isShuffle
{
    [self.playlist removeAllObjects];
    [self.playlist addObjectsFromArray:listSongs];
    
    CoreMusicPlayer *musicPlayer = [CoreMusicPlayer sharedInstance];
    [musicPlayer removeAllItems];
    
    [musicPlayer setPlayerRepeatMode:CoreMusicPlayerRepeatModeOff];
    
    if (isShuffle) {
        [musicPlayer setPlayerShuffleMode:CoreMusicPlayerShuffleModeOn];
    }
    
    [self setDelegate];
    [musicPlayer fetchAndPlayPlayerItem:0];
}

- (void)playWithSong:(Item *)song
{
    // check if song is in playlist -> play song
}

#pragma mark - CoreMusicPlayer

- (NSInteger)numberOfItems
{
    return self.playlist.count;
}

- (NSURL *)URLForItemAtIndex:(NSInteger)index preBuffer:(BOOL)preBuffer;
{
    Item *song = self.playlist[index];
    return song.sPlayableUrl;
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

- (void)playerWillChangedAtIndex:(NSInteger)index
{
    Item *song = self.playlist[index];
    [self setupUIWithSong:song];
}

- (void)setupUIWithSong:(Item *)song
{
    self.lblSongName.text = song.sSongName;
    self.lblSongDesc.text = song.sSongPlayerDesc;
}

- (void)playerDidReachEnd
{
    
}

- (void)playerStateChanged:(CoreMusicPlayerStatus)iStatus
{
    [self hideAll];
    
    switch (iStatus)
    {
//        case CoreMusicPlayerStatusUnknown:
//        case CoreMusicPlayerStatusBuffering:
//        {
//            self.loadingView.hidden = NO;
//        }
//            break;
//            
        case CoreMusicPlayerStatusPlaying:
            self.btnPause.hidden = NO;
            break;

        case CoreMusicPlayerStatusForcePause:
            self.btnPlay.hidden = NO;
            break;
            
        default:
            self.loadingView.hidden = NO;
            break;
    }
}

- (void)hideAll
{
    self.btnPlay.hidden = YES;
    self.btnPause.hidden = YES;
    self.loadingView.hidden = YES;
}

#pragma mark - Action

- (void)fastFoward
{
    isSeek = YES;
    NSLog(@"farstFoward begin");
}

- (void)nextSong
{
    if (!isSeek) {
        [[CoreMusicPlayer sharedInstance] playNext];
    }
    isSeek = NO;
}

- (void)rewind
{
    isSeek = YES;
    NSLog(@"farstBackward begin");
}

- (void)prevSong
{
    if (!isSeek) {
        [[CoreMusicPlayer sharedInstance] playPrevious];
    }
    isSeek = NO;
}

- (void)play
{
    [[CoreMusicPlayer sharedInstance] play];
}

- (void)pause
{
    [[CoreMusicPlayer sharedInstance] pause];
}

#pragma mark - UI

- (void)setupUI
{
    self.title = @"1 of 1";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnClose];
    
    [self setupControlPlayer];
    [self setupSeekView];
    [self setupInfoView];
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
    UIImage *nextHighlightedImage = [Utils tranlucentImage:[self.btnNext imageForState:UIControlStateNormal] withAlpha:0.6];
    [self.btnNext setImage:nextHighlightedImage forState:UIControlStateHighlighted];
    [self.btnNext addTarget:self action:@selector(fastFoward) forTouchAndHoldControlEventWithTimeInterval:FARST_SEEK_TIME];
    [self.btnNext addTarget:self action:@selector(nextSong) forControlEvents:UIControlEventTouchUpInside];
    
    //
    UIImage *prevHighlightedImage = [Utils tranlucentImage:[self.btnPrev imageForState:UIControlStateNormal] withAlpha:0.6];
    [self.btnPrev setImage:prevHighlightedImage forState:UIControlStateHighlighted];
    [self.btnPrev addTarget:self action:@selector(rewind) forTouchAndHoldControlEventWithTimeInterval:FARST_SEEK_TIME];
    [self.btnPrev addTarget:self action:@selector(prevSong) forControlEvents:UIControlEventTouchUpInside];
    
    //
    UIImage *playHighlightedImage = [Utils tranlucentImage:[self.btnPlay imageForState:UIControlStateNormal] withAlpha:0.6];
    [self.btnPlay setImage:playHighlightedImage forState:UIControlStateHighlighted];
    [self.btnPlay addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    
    //
    UIImage *pauseHighlightedImage = [Utils tranlucentImage:[self.btnPause imageForState:UIControlStateNormal] withAlpha:0.6];
    [self.btnPause setImage:pauseHighlightedImage forState:UIControlStateHighlighted];
    [self.btnPause addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupInfoView
{
    self.lblSongName.backgroundColor = [UIColor clearColor];
    self.lblSongName.textAlignment = NSTextAlignmentCenter;
    self.lblSongName.marqueeType = MLContinuous;
    self.lblSongName.scrollDuration = 10.0f;
    self.lblSongName.rate = 20.0f;
    self.lblSongName.fadeLength = 1.0f;
    self.lblSongName.trailingBuffer = 50.0f;
    self.lblSongName.animationDelay = 1.0f;
    
    self.lblSongDesc.backgroundColor = [UIColor clearColor];
    self.lblSongDesc.textAlignment = NSTextAlignmentCenter;
    self.lblSongDesc.marqueeType = MLContinuous;
    self.lblSongDesc.scrollDuration = 10.0f;
    self.lblSongDesc.rate = 20.0f;
    self.lblSongDesc.fadeLength = 1.0f;
    self.lblSongDesc.trailingBuffer = 30.0f;
    self.lblSongDesc.animationDelay = 1.0f;
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

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

#import "CurrentSongCollectionCell.h"

#import "DataManagement.h"
#import "GlobalParameter.h"

#import "NBTouchAndHoldButton.h"
#import "MarqueeLabel.h"
#import "HWViewPager.h"

static PlayerViewController *sharedInstance = nil;

@interface PlayerViewController () <CoreMusicPlayerDataSource,CoreMusicPlayerDelegate>
{
    BOOL isSeek, isSeeking;
    id mTimeObserver;
    NSInteger iCurrentIndex;
    
    BOOL isShowPlaylist;
    
    UIImage *defaultArtwork;
    UIImage *repeat, *repeat_once, *repeat_on;
    UIImage *shuffle, *shuffle_on;
    UIImage *bgOn, *bgOff;
}

@property (nonatomic, strong) UIButton *btnClose;
@property (nonatomic, strong) UIImageView *imgvMiniArtwork, *imgvShowPlaylist;
@property (nonatomic, strong) UIButton *btnSwitch;

@property (nonatomic, weak) IBOutlet UIView *line;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *lblTitle;

@property (nonatomic, weak) IBOutlet UIView *vPlayer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *vPlayerHeight;

@property (nonatomic, weak) IBOutlet UIView *vControlPlayer, *vInfoPlayer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *vControlPlayerWidth, *vInfoPlayerWidth;

@property (nonatomic, weak) IBOutlet MarqueeLabel *lblSongName, *lblSongDesc;
@property (nonatomic, weak) IBOutlet UITextView *tvLyrics;
@property (nonatomic, weak) IBOutlet UITableView *tblPlaylist;
@property (nonatomic, weak) IBOutlet HWViewPager *collectionPlaylist;

@property (nonatomic, weak) IBOutlet UIButton *btnPlay, *btnPause;
@property (nonatomic, weak) IBOutlet UIButton *btnTimer;
@property (nonatomic, weak) IBOutlet NBTouchAndHoldButton *btnNext, *btnPrev;

@property (nonatomic, weak) IBOutlet MPVolumeView *volumeSlider;
@property (nonatomic, weak) IBOutlet UIButton *btnRepeat, *btnShuffle;

@property (nonatomic, weak) IBOutlet UILabel *lblCurrent, *lblRemain;
@property (nonatomic, weak) IBOutlet UISlider *seekSlider;

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
        [self initData];
    }
    return self;
}

- (void)initData
{
    defaultArtwork = [UIImage imageNamed:@"white-default-cover"];
    
    repeat = [UIImage imageNamed:@"repeat"];
    repeat_on = [UIImage imageNamed:@"repeat_on"];
    repeat_once = [UIImage imageNamed:@"repeat_once"];
    
    shuffle = [UIImage imageNamed:@"shuffle"];
    shuffle_on = [UIImage imageNamed:@"shuffle_on"];
    
    bgOn = [Utils imageWithColor:0x006bd5];
    bgOff = [Utils imageWithColor:0xffffff];
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

- (void)playWithSong:(Item *)song
{
    [self playWithPlaylist:@[song] isShuffle:NO];
}

- (void)playWithPlaylist:(NSArray *)listSongs isShuffle:(BOOL)isShuffle
{
    [self.playlist removeAllObjects];
    [self.playlist addObjectsFromArray:listSongs];
    
    [self setDelegate];
    
    CoreMusicPlayer *musicPlayer = [CoreMusicPlayer sharedInstance];
    [musicPlayer removeAllItems];
    [musicPlayer setPlayerShuffleMode:isShuffle ? CoreMusicPlayerShuffleModeOn:CoreMusicPlayerShuffleModeOff];
    [self configShuffleButton:isShuffle ? CoreMusicPlayerShuffleModeOn:CoreMusicPlayerShuffleModeOff];
    
    iCurrentIndex = isShuffle ? ((int)(arc4random() % [self.playlist count])) : 0;
    [musicPlayer fetchAndPlayPlayerItem:0];
    
    [self.collectionPlaylist reloadData];
    [self.tblPlaylist reloadData];
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
    if (iStatus != CoreMusicPlayerReadyToPlayPlayer) {
        return;
    }
    
    if (mTimeObserver != nil)
    {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    mTimeObserver = [[CoreMusicPlayer sharedInstance] addPeriodicTimeObserverForInterval:CMTimeMake(10, 1000)
                                                                                   queue:NULL
                                                                              usingBlock:^(CMTime time)
    {
        if (!isSeeking) {
            CoreMusicPlayer *musicPlayer = [CoreMusicPlayer sharedInstance];
            float currentTime = [musicPlayer getPlayingItemCurrentTime];
            float duration = [musicPlayer getPlayingItemDurationTime];
            
            weakSelf.seekSlider.value = (float)currentTime/duration;
            weakSelf.lblCurrent.text = [Utils timeFormattedForSong:currentTime];
            weakSelf.lblRemain.text = [NSString stringWithFormat:@"-%@",[Utils timeFormattedForSong:fabs(duration - currentTime)]];
        }
    }];
}

- (void)playerStateChanged:(CoreMusicPlayerStatus)iStatus
{
    self.btnPlay.hidden = YES;
    self.btnPause.hidden = YES;
    
    switch (iStatus)
    {
        case CoreMusicPlayerStatusBuffering:
        case CoreMusicPlayerStatusPlaying:
        {
            [[GlobalParameter sharedInstance] startPlay];
            self.btnPause.hidden = NO;
            break;
        }
            
        case CoreMusicPlayerStatusForcePause:
        {
            [[GlobalParameter sharedInstance] pausePlay];
            self.btnPlay.hidden = NO;
        }
            break;

        default:
            self.btnPlay.hidden = NO;
            break;
    }
}

- (void)playerWillChangedAtIndex:(NSInteger)index
{
    iCurrentIndex = index;
    [self configCurrentPlay:index];
}

- (void)playerDidReachEnd
{
    
}

#pragma mark - Action

- (void)seeking:(UISlider *)sender
{
    isSeeking = YES;
    
    CoreMusicPlayer *musicPlayer = [CoreMusicPlayer sharedInstance];
    float duration = [musicPlayer getPlayingItemDurationTime];
    float currentTime = ceilf(duration*(sender.value));
    
    self.lblCurrent.text = [Utils timeFormattedForSong:currentTime];
    self.lblRemain.text = [NSString stringWithFormat:@"-%@",[Utils timeFormattedForSong:fabs(duration - currentTime)]];
}

- (void)endSeek:(UISlider *)sender
{
    CoreMusicPlayer *musicPlayer = [CoreMusicPlayer sharedInstance];
    float seekTime = ceilf([musicPlayer getPlayingItemDurationTime]*(sender.value));
    
    [musicPlayer seekToTime:seekTime withCompletionBlock:^(BOOL finished) {
        isSeeking = NO;
    }];
}

- (void)fastFoward
{
    isSeek = YES;
    
    CoreMusicPlayer *musicPlayer = [CoreMusicPlayer sharedInstance];
    double seekTime = [musicPlayer getPlayingItemCurrentTime] + 2.0;
    [musicPlayer seekToTime:seekTime];
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
    
    CoreMusicPlayer *musicPlayer = [CoreMusicPlayer sharedInstance];
    double seekTime = [musicPlayer getPlayingItemCurrentTime] - 2.0;
    [musicPlayer seekToTime:seekTime];
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

- (void)setTimer
{
    
}

#pragma mark - ExternalAction

- (void)touchRepeat
{
    CoreMusicPlayer *musicPlayer = [CoreMusicPlayer sharedInstance];
    CoreMusicPlayerRepeatMode iRepeatMode = [musicPlayer getPlayerRepeatMode];
    
    if (iRepeatMode == CoreMusicPlayerRepeatModeOff) {
        iRepeatMode = CoreMusicPlayerRepeatModeOn;
    }
    else if (iRepeatMode == CoreMusicPlayerRepeatModeOn) {
        iRepeatMode = CoreMusicPlayerRepeatModeOnce;
    }
    else if (iRepeatMode == CoreMusicPlayerRepeatModeOnce) {
        iRepeatMode = CoreMusicPlayerRepeatModeOff;
    }
    
    [musicPlayer setPlayerRepeatMode:iRepeatMode];
    [self configRepeatButton:iRepeatMode];
}

- (void)configRepeatButton:(CoreMusicPlayerRepeatMode)iRepeatMode
{
    if (iRepeatMode == CoreMusicPlayerRepeatModeOff) {
        [self.btnRepeat setImage:repeat forState:UIControlStateNormal];
        [self.btnRepeat setBackgroundImage:bgOff forState:UIControlStateNormal];
    }
    else if (iRepeatMode == CoreMusicPlayerRepeatModeOn) {
        [self.btnRepeat setImage:repeat_on forState:UIControlStateNormal];
        [self.btnRepeat setBackgroundImage:bgOn forState:UIControlStateNormal];
    }
    else if (iRepeatMode == CoreMusicPlayerRepeatModeOnce) {
        [self.btnRepeat setImage:repeat_once forState:UIControlStateNormal];
        [self.btnRepeat setBackgroundImage:bgOn forState:UIControlStateNormal];
    }
}

- (void)touchShuffle
{
    CoreMusicPlayer *musicPlayer = [CoreMusicPlayer sharedInstance];
    CoreMusicPlayerShuffleMode iShuffleMode = [musicPlayer getPlayerShuffleMode];
    
    if (iShuffleMode == CoreMusicPlayerShuffleModeOn) {
        iShuffleMode = CoreMusicPlayerShuffleModeOff;
    }
    else if (iShuffleMode == CoreMusicPlayerShuffleModeOff) {
        iShuffleMode = CoreMusicPlayerShuffleModeOn;
    }
    
    [musicPlayer setPlayerShuffleMode:iShuffleMode];
    [self configShuffleButton:iShuffleMode];
}

- (void)configShuffleButton:(CoreMusicPlayerShuffleMode)iShuffleMode
{
    if (iShuffleMode == CoreMusicPlayerShuffleModeOn) {
        [self.btnShuffle setImage:shuffle_on forState:UIControlStateNormal];
        [self.btnShuffle setBackgroundImage:bgOn forState:UIControlStateNormal];
    }
    else if (iShuffleMode == CoreMusicPlayerShuffleModeOff) {
        [self.btnShuffle setImage:shuffle forState:UIControlStateNormal];
        [self.btnShuffle setBackgroundImage:bgOff forState:UIControlStateNormal];
    }
}

#pragma mark - CollectionPlaylist

- (void)pagerDidSelectedPage:(NSInteger)selectedPage
{
    if (iCurrentIndex < selectedPage) {
        [[CoreMusicPlayer sharedInstance] playNext];
    }
    else if (iCurrentIndex > selectedPage) {
        [[CoreMusicPlayer sharedInstance] playPrevious];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.playlist.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CurrentSongCollectionCell *cell = (CurrentSongCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CurrentSongCollectionCellId" forIndexPath:indexPath];
    
    Item *song = self.playlist[indexPath.item];
    [cell configWithSong:song];
    
    return cell;
}

#pragma mark - ConfigUI

- (void)configCurrentPlay:(NSInteger)iIndex
{
    [self.collectionPlaylist setPage:iIndex isAnimation:YES isNotify:NO];
    [self setCurrentTitle:[NSString stringWithFormat:@"%ld of %ld",(iIndex + 1),self.playlist.count]];
    
    Item *song = self.playlist[iIndex];
    [[GlobalParameter sharedInstance] setCurrentPlaying:song];
    
    NSString *sSongTitle = song.sSongName;
    NSString *sSongDesc = song.sSongPlayerDesc;
    
    NSString *sLyrics = song.sLyrics;
    if (!sLyrics) {
        sLyrics = @"No Lyrics";
    }
    
    UIImage *imgArtwork = nil;
    if (song.sLocalArtworkUrl) {
        imgArtwork = [UIImage imageWithContentsOfFile:song.sLocalArtworkUrl.path];
    }
    else {
        imgArtwork = defaultArtwork;
    }
    
    self.lblSongName.text = sSongTitle;
    self.lblSongDesc.text = sSongDesc;
    self.tvLyrics.text = sLyrics;
    
    NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
    if (sSongTitle) {
        [songInfo setObject:sSongTitle forKey:MPMediaItemPropertyTitle];
    }
    if (sSongDesc) {
        [songInfo setObject:sSongDesc forKey:MPMediaItemPropertyAlbumTitle];
    }
    
    [songInfo setObject:[[MPMediaItemArtwork alloc] initWithImage:imgArtwork] forKey:MPMediaItemPropertyArtwork];
    [songInfo setObject:sLyrics forKey:MPMediaItemPropertyLyrics];
    [songInfo setObject:[NSNumber numberWithInt:1] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    [songInfo setObject:song.fDuration forKey:MPMediaItemPropertyPlaybackDuration];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    [self setEnableRemoteControl:YES];
}

#pragma mark - UI

- (void)setupUI
{
    self.navigationItem.titleView = self.titleView;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnClose];
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xb2b2b2];
    
    [self setupCollectionPlaylist];
    [self setupControlPlayer];
    [self setupSeekView];
    [self setupInfoView];
    [self setupVolumeSlider];
    [self setupExternalControl];
    [self setupRemoteControl];
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
    
    //
    UIImage *timerHighlightedImage = [Utils tranlucentImage:[self.btnTimer imageForState:UIControlStateNormal] withAlpha:0.6];
    [self.btnTimer setImage:timerHighlightedImage forState:UIControlStateHighlighted];
    [self.btnTimer addTarget:self action:@selector(setTimer) forControlEvents:UIControlEventTouchUpInside];
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
    [self.seekSlider setMinimumTrackImage:[UIImage imageNamed:@"maxTrack"] forState:UIControlStateNormal];
    [self.seekSlider setMaximumTrackImage:[UIImage imageNamed:@"minTrack"] forState:UIControlStateNormal];
    [self.seekSlider setThumbImage:[UIImage imageNamed:@"thumbTrack"] forState:UIControlStateNormal];
    
    [self.seekSlider addTarget:self action:@selector(seeking:) forControlEvents:UIControlEventValueChanged];
    [self.seekSlider addTarget:self action:@selector(endSeek:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
}

- (void)setupVolumeSlider
{
    [self.volumeSlider setShowsRouteButton:NO];
    [self.volumeSlider setMinimumVolumeSliderImage:[UIImage imageNamed:@"maxVolumeTrack"] forState:UIControlStateNormal];
    [self.volumeSlider setMaximumVolumeSliderImage:[UIImage imageNamed:@"minVolumeTrack"] forState:UIControlStateNormal];
    [self.volumeSlider setVolumeThumbImage:[UIImage imageNamed:@"thumbVolume"] forState:UIControlStateNormal];
}

- (void)setupExternalControl
{
    [[CoreMusicPlayer sharedInstance] setPlayerRepeatMode:CoreMusicPlayerRepeatModeOn];
    [self configRepeatButton:CoreMusicPlayerRepeatModeOn];
    self.btnRepeat.layer.cornerRadius = 4.0;
    self.btnRepeat.clipsToBounds = YES;
    [self.btnRepeat addTarget:self action:@selector(touchRepeat) forControlEvents:UIControlEventTouchUpInside];
    
    [[CoreMusicPlayer sharedInstance] setPlayerShuffleMode:CoreMusicPlayerShuffleModeOff];
    [self configShuffleButton:CoreMusicPlayerShuffleModeOff];
    self.btnShuffle.layer.cornerRadius = 4.0;
    self.btnShuffle.clipsToBounds = YES;
    [self.btnShuffle addTarget:self action:@selector(touchShuffle) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupCollectionPlaylist
{
    [self.collectionPlaylist registerNib:[UINib nibWithNibName:@"CurrentSongCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"CurrentSongCollectionCellId"];
    [self.collectionPlaylist setBounces:YES];
    [self.collectionPlaylist setAlwaysBounceVertical:NO];
    [self.collectionPlaylist setAlwaysBounceHorizontal:YES];
    [self.collectionPlaylist setDirectionalLockEnabled:YES];
    
    [self.collectionPlaylist setBackgroundColor:[Utils colorWithRGBHex:0xf4f4f4]];
    [self.collectionPlaylist setShowsHorizontalScrollIndicator:NO];
    [self.collectionPlaylist setShowsVerticalScrollIndicator:NO];
}

- (void)setupRemoteControl
{
    MPRemoteCommandCenter *rcc = [MPRemoteCommandCenter sharedCommandCenter];
    
    [[rcc pauseCommand] addTarget:self action:@selector(pause)];
    [[rcc playCommand] addTarget:self action:@selector(play)];
    
    [[rcc nextTrackCommand] addTarget:self action:@selector(nextSong)];
    [[rcc previousTrackCommand] addTarget:self action:@selector(prevSong)];
    
    [[rcc seekForwardCommand] addTarget:self action:@selector(fastFoward)];
    [[rcc seekBackwardCommand] addTarget:self action:@selector(rewind)];
}

- (void)setEnableRemoteControl:(BOOL)isEnable
{
    MPRemoteCommandCenter *rcc = [MPRemoteCommandCenter sharedCommandCenter];
    
    [[rcc pauseCommand] setEnabled:isEnable];
    [[rcc playCommand] setEnabled:isEnable];
    [[rcc nextTrackCommand] setEnabled:isEnable];
    [[rcc previousTrackCommand] setEnabled:isEnable];
    [[rcc seekForwardCommand] setEnabled:isEnable];
    [[rcc seekBackwardCommand] setEnabled:isEnable];
}

- (void)resetRemoteCenter
{
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
}

- (UIView *)titleView
{
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 40.0)];
        _titleView.backgroundColor = [UIColor clearColor];
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 40.0)];
        self.lblTitle.backgroundColor = [UIColor clearColor];
        self.lblTitle.textColor = [UIColor darkTextColor];
        self.lblTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
        self.lblTitle.textAlignment = NSTextAlignmentCenter;

        [_titleView addSubview:self.lblTitle];
    }
    return _titleView;
}

- (UIButton *)btnClose
{
    if (!_btnClose) {
        _btnClose = [Utils createBarButton:@"btn_close_player" position:UIControlContentHorizontalAlignmentLeft target:self selector:@selector(closeView)];
    }
    return _btnClose;
}

- (void)setCurrentTitle:(NSString *)sTitle
{
    self.lblTitle.text = sTitle;
}

- (void)closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

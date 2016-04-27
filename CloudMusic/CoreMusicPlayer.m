//
//  MochaMusicPlayer.m
//  HyseteriaSamples
//
//  Created by TuanTN8 on 4/11/16.
//  Copyright © 2016 saiday. All rights reserved.
//

#import "CoreMusicPlayer.h"

static const void *MusicTag = &MusicTag;

@interface CoreMusicPlayer()
{
    BOOL routeChangedWhilePlaying;
    BOOL interruptedWhilePlaying;
    BOOL pauseReasonForced;
    BOOL pauseReasonBuffering;
    BOOL isPreBuffered;
    BOOL tookAudioFocus;
    
    UIBackgroundTaskIdentifier bgTaskId;
    UIBackgroundTaskIdentifier removedId;
    
    dispatch_queue_t MusicBackgroundQueue;
}

@property (nonatomic, strong, readwrite) NSArray *playerItems;
@property (nonatomic) NSInteger lastItemIndex;

@property (nonatomic) CoreMusicPlayerRepeatMode repeatMode;
@property (nonatomic) CoreMusicPlayerShuffleMode shuffleMode;
@property (nonatomic) CoreMusicPlayerStatus mochaMusicStatus;
@property (nonatomic, strong) NSMutableSet *playedItems;

- (void)longTimeBufferBackground;
- (void)longTimeBufferBackgroundCompleted;

@end

@implementation CoreMusicPlayer

#pragma mark - Init

static CoreMusicPlayer *sharedInstance = nil;
static dispatch_once_t onceToken;

+ (CoreMusicPlayer *)sharedInstance {
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        MusicBackgroundQueue = dispatch_queue_create("com.mocha.music.queue", NULL);
        _playerItems = [NSArray array];
        
        _repeatMode = CoreMusicPlayerRepeatModeOff;
        _shuffleMode = CoreMusicPlayerShuffleModeOff;
        _mochaMusicStatus = CoreMusicPlayerStatusUnknown;
    }
    
    return self;
}

- (void)setIndex:(AVPlayerItem *)item key:(NSNumber *)order {
    objc_setAssociatedObject(item, MusicTag, order, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)getIndex:(AVPlayerItem *)item {
    return objc_getAssociatedObject(item, MusicTag);
}

- (void)preAction
{
    tookAudioFocus = YES;
    
    [self backgroundPlayable];
    self.audioPlayer = [[AVQueuePlayer alloc] init];
    [self AVAudioSessionNotification];
}

- (void)backgroundPlayable
{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    
    [session setMode:AVAudioSessionModeDefault error:&error];
    if (error) {
        NSLog(@"%@", error.description);
    }
    
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSLog(@"%@", error.description);
    }
    
    [session setActive:YES error:&error];
    if (error) {
        NSLog(@"%@", error.description);
    }
    
    [self longTimeBufferBackground];
}

- (void)longTimeBufferBackground
{
    bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:removedId];
        bgTaskId = UIBackgroundTaskInvalid;
    }];
    
    if (bgTaskId != UIBackgroundTaskInvalid && removedId == 0 ? YES : (removedId != UIBackgroundTaskInvalid)) {
        [[UIApplication sharedApplication] endBackgroundTask: removedId];
    }
    removedId = bgTaskId;
}

- (void)longTimeBufferBackgroundCompleted
{
    if (bgTaskId != UIBackgroundTaskInvalid && removedId != bgTaskId) {
        [[UIApplication sharedApplication] endBackgroundTask: bgTaskId];
        removedId = bgTaskId;
    }
}

#pragma mark - AVAudioSessionNotifications

- (void)AVAudioSessionNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemFailedToPlayEndTime:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemPlaybackStall:)
                                                 name:AVPlayerItemPlaybackStalledNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interruption:)
                                                 name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    
    [self.audioPlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    [self.audioPlayer addObserver:self forKeyPath:@"rate" options:0 context:nil];
    [self.audioPlayer addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

#pragma mark - PlayerMethods

- (void)willPlayPlayerItemAtIndex:(NSInteger)index
{
    if (!tookAudioFocus) {
        [self preAction];
    }
    
    self.lastItemIndex = index;
    [self.playedItems addObject:@(index)];
    
    if ([self.delegate respondsToSelector:@selector(playerWillChangedAtIndex:)]) {
        [self.delegate playerWillChangedAtIndex:self.lastItemIndex];
    }
}

- (void)fetchAndPlayPlayerItem:(NSInteger)startAt
{
    [self willPlayPlayerItemAtIndex:startAt];
    [self.audioPlayer pause];
    [self.audioPlayer removeAllItems];
    
    BOOL findInPlayerItems = [self findSourceInPlayerItems:startAt];
    
    if (!findInPlayerItems) {
        [self getSourceURLAtIndex:startAt preBuffer:NO];
    }
    else if (self.audioPlayer.currentItem.status == AVPlayerStatusReadyToPlay) {
        [self.audioPlayer play];
    }
}

- (NSInteger)numberOfItems
{
    if ([self.datasource respondsToSelector:@selector(numberOfItems)]) {
        return [self.datasource numberOfItems];
    }
    return self.itemsCount;
}

- (void)getSourceURLAtIndex:(NSInteger)index preBuffer:(BOOL)preBuffer
{
    if ([self.datasource respondsToSelector:@selector(URLForItemAtIndex:preBuffer:)] &&
        [self.datasource URLForItemAtIndex:index preBuffer:preBuffer])
    {
        pauseReasonForced = NO;
        
        dispatch_async(MusicBackgroundQueue, ^{
            [self setupPlayerItemWithUrl:[self.datasource URLForItemAtIndex:index preBuffer:preBuffer] index:index];
        });
    }
    else {
        NSException *exception = [[NSException alloc] initWithName:@"mochaMusic Error" reason:[NSString stringWithFormat:@"Cannot find item URL at index %li", (unsigned long)index] userInfo:nil];
        @throw exception;
    }
}

- (void)setupPlayerItemWithUrl:(NSURL *)url index:(NSInteger)index
{
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    if (!item)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setIndex:item key:[NSNumber numberWithInteger:index]];
        
        if (self.isMemoryCached) {
            NSMutableArray *playerItems = [NSMutableArray arrayWithArray:self.playerItems];
            [playerItems addObject:item];
            self.playerItems = playerItems;
        }
        [self insertPlayerItem:item];
    });
}

- (BOOL)findSourceInPlayerItems:(NSInteger)index
{
    for (AVPlayerItem *item in self.playerItems)
    {
        NSInteger checkIndex = [[self getIndex:item] integerValue];
        if (checkIndex == index) {
            [item seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
                [self insertPlayerItem:item];
            }];
            return YES;
        }
    }
    return NO;
}

- (void)insertPlayerItem:(AVPlayerItem *)item
{
    if ([self.audioPlayer.items count] > 1) {
        for (int i = 1 ; i < [self.audioPlayer.items count] ; i ++) {
            [self.audioPlayer removeItem:[self.audioPlayer.items objectAtIndex:i]];
        }
    }
    
    if ([self.audioPlayer canInsertItem:item afterItem:nil]) {
        [self.audioPlayer insertItem:item afterItem:nil];
    }
}

- (void)removeAllItems
{
    for (AVPlayerItem *obj in self.audioPlayer.items)
    {
        [obj seekToTime:kCMTimeZero];
        
        @try {
            [obj removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
            [obj removeObserver:self forKeyPath:@"status" context:nil];
        }
        @catch(id anException) {}
    }
    
    self.playerItems = [self isMemoryCached] ? [NSArray array] : nil;
    [self.audioPlayer removeAllItems];
}

- (void)removeQueuesAtPlayer
{
    while (self.audioPlayer.items.count > 1) {
        [self.audioPlayer removeItem:[self.audioPlayer.items objectAtIndex:1]];
    }
}

- (void)removeItemAtIndex:(NSInteger)index
{
    if ([self isMemoryCached])
    {
        for (AVPlayerItem *item in [NSArray arrayWithArray:self.playerItems]) {
            NSInteger checkIndex = [[self getIndex:item] integerValue];
            if (checkIndex == index)
            {
                NSMutableArray *playerItems = [NSMutableArray arrayWithArray:self.playerItems];
                [playerItems removeObject:item];
                self.playerItems = playerItems;
                
                if ([self.audioPlayer.items indexOfObject:item] != NSNotFound) {
                    [self.audioPlayer removeItem:item];
                }
            }
            else if (checkIndex > index) {
                [self setIndex:item key:[NSNumber numberWithInteger:checkIndex -1]];
            }
        }
    }
    else {
        for (AVPlayerItem *item in self.audioPlayer.items) {
            NSInteger checkIndex = [[self getIndex:item] integerValue];
            if (checkIndex == index) {
                [self.audioPlayer removeItem:item];
            }
            else if (checkIndex > index) {
                [self setIndex:item key:[NSNumber numberWithInteger:checkIndex -1]];
            }
        }
    }
}

- (void)moveItemFromIndex:(NSInteger)from toIndex:(NSInteger)to
{
    for (AVPlayerItem *item in self.playerItems) {
        [self resetItemIndexIfNeeds:item fromIndex:from toIndex:to];
    }
    
    for (AVPlayerItem *item in self.audioPlayer.items) {
        if ([self resetItemIndexIfNeeds:item fromIndex:from toIndex:to]) {
            [self removeQueuesAtPlayer];
        }
    }
}

- (BOOL)resetItemIndexIfNeeds:(AVPlayerItem *)item fromIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex
{
    NSInteger checkIndex = [[self getIndex:item] integerValue];
    BOOL found = NO;
    NSNumber *replaceOrder;
    
    if (checkIndex == sourceIndex) {
        replaceOrder = [NSNumber numberWithInteger:destinationIndex];
        found = YES;
    }
    else if (checkIndex == destinationIndex) {
        replaceOrder = sourceIndex > checkIndex ? @(checkIndex + 1) : @(checkIndex - 1);
        found = YES;
    }
    else if (checkIndex > destinationIndex && checkIndex < sourceIndex) {
        replaceOrder = [NSNumber numberWithInteger:(checkIndex + 1)];
        found = YES;
    }
    else if (checkIndex < destinationIndex && checkIndex > sourceIndex) {
        replaceOrder = [NSNumber numberWithInteger:(checkIndex - 1)];
        found = YES;
    }
    
    if (replaceOrder) {
        [self setIndex:item key:replaceOrder];
        if (self.lastItemIndex == checkIndex) {
            self.lastItemIndex = [replaceOrder integerValue];
        }
    }
    return found;
}

- (void)seekToTime:(double)seconds
{
    [self.audioPlayer seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC)];
}

- (void)seekToTime:(double)seconds withCompletionBlock:(void (^)(BOOL))completionBlock
{
    [self.audioPlayer seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        if (completionBlock) {
            completionBlock(finished);
        }
    }];
}

- (void)play
{
    pauseReasonForced = NO;
    
    if (![self isPlaying]) {
        [self.audioPlayer play];
    }
}

- (void)pause
{
    pauseReasonForced = YES;
    [self.audioPlayer pause];
}

- (void)playNext
{
    if (_shuffleMode == CoreMusicPlayerShuffleModeOn) {
        NSInteger nextIndex = [self randomIndex];
        if (nextIndex != NSNotFound) {
            [self fetchAndPlayPlayerItem:nextIndex];
        } 
        else {
            pauseReasonForced = YES;
            if ([self.delegate respondsToSelector:@selector(playerDidReachEnd)]) {
                [self.delegate playerDidReachEnd];
            }
        }
    }
    else {
        NSNumber *nowIndexNumber = [self getIndex:self.audioPlayer.currentItem];
        NSInteger nowIndex = nowIndexNumber ? [nowIndexNumber integerValue] : self.lastItemIndex;
        
        if (nowIndex + 1 < [self numberOfItems]) {
            if (self.audioPlayer.items.count > 1) {
                [self willPlayPlayerItemAtIndex:nowIndex + 1];
                [self.audioPlayer advanceToNextItem];
            }
            else {
                [self fetchAndPlayPlayerItem:(nowIndex + 1)];
            }
        }
        else {
            if (_repeatMode == CoreMusicPlayerRepeatModeOff) {
                pauseReasonForced = YES;
                if ([self.delegate respondsToSelector:@selector(playerDidReachEnd)]) {
                    [self.delegate playerDidReachEnd];
                }
            }
            else {
                [self fetchAndPlayPlayerItem:0];
            }
        }
    }
}

- (void)playPrevious
{
    NSInteger nowIndex = [[self getIndex:self.audioPlayer.currentItem] integerValue];
    if (nowIndex == 0)
    {
        if (_repeatMode == CoreMusicPlayerRepeatModeOn) {
            [self fetchAndPlayPlayerItem:[self numberOfItems] - 1];
        } else {
            [self.audioPlayer.currentItem seekToTime:kCMTimeZero];
        }
    } else {
        [self fetchAndPlayPlayerItem:(nowIndex - 1)];
    }
}

- (CMTime)playerItemDuration
{
    NSError *err = nil;
    if ([self.audioPlayer.currentItem.asset statusOfValueForKey:@"duration" error:&err] == AVKeyValueStatusLoaded) {
        AVPlayerItem *playerItem = [self.audioPlayer currentItem];
        NSArray *loadedRanges = playerItem.seekableTimeRanges;
        if (loadedRanges.count > 0)
        {
            CMTimeRange range = [[loadedRanges objectAtIndex:0] CMTimeRangeValue];
            //Float64 duration = CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration);
            return (range.duration);
        }else {
            return (kCMTimeInvalid);
        }
    } else {
        return (kCMTimeInvalid);
    }
}

- (void)setPlayerRepeatMode:(CoreMusicPlayerRepeatMode)mode
{
    _repeatMode = mode;
}

- (CoreMusicPlayerRepeatMode)getPlayerRepeatMode
{
    return _repeatMode;
}

- (void)setPlayerShuffleMode:(CoreMusicPlayerShuffleMode)mode
{
    switch (mode)
    {
        case CoreMusicPlayerShuffleModeOff:
            _shuffleMode = CoreMusicPlayerShuffleModeOff;
            [_playedItems removeAllObjects];
            _playedItems = nil;
            break;
            
        case CoreMusicPlayerShuffleModeOn:
            _shuffleMode = CoreMusicPlayerShuffleModeOn;
            _playedItems = [NSMutableSet set];
            if (self.audioPlayer.currentItem) {
                [self.playedItems addObject:[self getIndex:self.audioPlayer.currentItem]];
            }
            break;
            
        default:
            break;
    }
}

- (CoreMusicPlayerShuffleMode)getPlayerShuffleMode
{
    return _shuffleMode;
}

#pragma mark - PlayerInfo

- (BOOL)isPlaying
{
    return self.audioPlayer.rate != 0.f;
}

- (CoreMusicPlayerStatus)getCoreMusicPlayerStatus
{
    if ([self isPlaying]) {
        return CoreMusicPlayerStatusPlaying;
    }
    else if (pauseReasonForced) {
        return CoreMusicPlayerStatusForcePause;
    }
    else if (pauseReasonBuffering) {
        return CoreMusicPlayerStatusBuffering;
    }
    else {
        return CoreMusicPlayerStatusUnknown;
    }
}

- (float)getPlayingItemCurrentTime
{
    CMTime itemCurrentTime = [[self.audioPlayer currentItem] currentTime];
    float current = CMTimeGetSeconds(itemCurrentTime);
    if (CMTIME_IS_INVALID(itemCurrentTime) || !isfinite(current))
        return 0.0f;
    else
        return current;
}

- (float)getPlayingItemDurationTime
{
    CMTime itemDurationTime = [self playerItemDuration];
    float duration = CMTimeGetSeconds(itemDurationTime);
    if (CMTIME_IS_INVALID(itemDurationTime) || !isfinite(duration))
        return 0.0f;
    else
        return duration;
}

- (id)addBoundaryTimeObserverForTimes:(NSArray *)times queue:(dispatch_queue_t)queue usingBlock:(void (^)(void))block
{
    id boundaryObserver = [self.audioPlayer addBoundaryTimeObserverForTimes:times queue:queue usingBlock:block];
    return boundaryObserver;
}

- (id)addPeriodicTimeObserverForInterval:(CMTime)interval
                                   queue:(dispatch_queue_t)queue
                              usingBlock:(void (^)(CMTime time))block
{
    id mTimeObserver = [self.audioPlayer addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:block];
    return mTimeObserver;
}

- (void)removeTimeObserver:(id)observer
{
    [self.audioPlayer removeTimeObserver:observer];
}

#pragma mark - Notification for Interruption, Route changed

- (void)interruption:(NSNotification *)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    
    if (interuptionType == AVAudioSessionInterruptionTypeBegan &&
        !pauseReasonForced)
    {
        interruptedWhilePlaying = YES;
        pauseReasonForced = YES;
        [self pause];
    }
    else if (interuptionType == AVAudioSessionInterruptionTypeEnded &&
             interruptedWhilePlaying)
    {
        interruptedWhilePlaying = NO;
        pauseReasonForced = NO;
        [self play];
    }
    
    NSLog(@"mochaMusic: mochaMusic interruption: %@", interuptionType == AVAudioSessionInterruptionTypeBegan ? @"began" : @"end");
}

- (void)routeChange:(NSNotification *)notification
{
    NSDictionary *routeChangeDict = notification.userInfo;
    NSInteger routeChangeType = [[routeChangeDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    if (routeChangeType == AVAudioSessionRouteChangeReasonOldDeviceUnavailable &&
        !pauseReasonForced)
    {
        routeChangedWhilePlaying = YES;
        pauseReasonForced = YES;
        [self pause];
    }
    else if (routeChangeType == AVAudioSessionRouteChangeReasonNewDeviceAvailable &&
             routeChangedWhilePlaying)
    {
        routeChangedWhilePlaying = NO;
        pauseReasonForced = NO;
        [self play];
    }
    
    NSLog(@"mochaMusic: mochaMusic routeChanged: %@", routeChangeType == AVAudioSessionRouteChangeReasonNewDeviceAvailable ? @"New Device Available" : @"Old Device Unavailable");
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.audioPlayer && [keyPath isEqualToString:@"status"])
    {
        if (self.audioPlayer.status == AVPlayerStatusReadyToPlay)
        {
            if ([self.delegate respondsToSelector:@selector(playerReadyToPlay:)]) {
                [self.delegate playerReadyToPlay:CoreMusicPlayerReadyToPlayPlayer];
            }
            
            if (![self isPlaying]) {
                [self.audioPlayer play];
            }
        }
        else if (self.audioPlayer.status == AVPlayerStatusFailed)
        {
            NSInteger currentItemIndex = [[self getIndex:self.audioPlayer.currentItem] integerValue];
            [self removeItemFromCache:currentItemIndex];
            
            if ([self.delegate respondsToSelector:@selector(playerDidFailed:atIndex:)]) {
                [self.delegate playerDidFailed:CoreMusicPlayerFailedPlayer atIndex:self.lastItemIndex];
            }
        }
    }
    
    if (object == self.audioPlayer && [keyPath isEqualToString:@"rate"]) {
        if ([self.delegate respondsToSelector:@selector(playerStateChanged:)]) {
            [self.delegate playerStateChanged:[self getCoreMusicPlayerStatus]];
        }
    }
    
    if (object == self.audioPlayer && [keyPath isEqualToString:@"currentItem"])
    {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        AVPlayerItem *lastPlayerItem = [change objectForKey:NSKeyValueChangeOldKey];
        if (lastPlayerItem != (id)[NSNull null]) {
            @try {
                [lastPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
                [lastPlayerItem removeObserver:self forKeyPath:@"status" context:nil];
            } @catch(id anException) {}
        }
        if (newPlayerItem != (id)[NSNull null]) {
            [newPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
            [newPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
            
            if ([self.delegate respondsToSelector:@selector(playerCurrentItemChanged:)]) {
                [self.delegate playerCurrentItemChanged:newPlayerItem];
            }
        }
    }
    
    if (object == self.audioPlayer.currentItem && [keyPath isEqualToString:@"status"])
    {
        isPreBuffered = NO;
        if (self.audioPlayer.currentItem.status == AVPlayerItemStatusFailed)
        {
            NSInteger currentItemIndex = [[self getIndex:self.audioPlayer.currentItem] integerValue];
            [self removeItemFromCache:currentItemIndex];
            
            if ([self.delegate respondsToSelector:@selector(playerDidFailed:atIndex:)]) {
                [self.delegate playerDidFailed:CoreMusicPlayerFailedCurrentItem atIndex:self.lastItemIndex];
            }
        }
        else if (self.audioPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay)
        {
            if ([self.delegate respondsToSelector:@selector(playerReadyToPlay:)]) {
                [self.delegate playerReadyToPlay:CoreMusicPlayerReadyToPlayCurrentItem];
            }
            
            if (![self isPlaying] && !pauseReasonForced) {
                [self.audioPlayer play];
            }
        }
    }
    
    if (self.audioPlayer.items.count > 1 &&
        object == [self.audioPlayer.items objectAtIndex:1] &&
        [keyPath isEqualToString:@"loadedTimeRanges"])
    {
        isPreBuffered = YES;
    }
    
    if (object == self.audioPlayer.currentItem &&
        [keyPath isEqualToString:@"loadedTimeRanges"])
    {
        NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
        if (timeRanges && [timeRanges count]) {
            CMTimeRange timerange = [[timeRanges objectAtIndex:0] CMTimeRangeValue];
            
            if ([self.delegate respondsToSelector:@selector(playerCurrentItemPreloaded:)])
            {
                [self.delegate playerCurrentItemPreloaded:CMTimeAdd(timerange.start, timerange.duration)];
            }
            
            if (self.audioPlayer.rate == 0 && !pauseReasonForced) {
                pauseReasonBuffering = YES;
                [self longTimeBufferBackground];
                
                CMTime bufferdTime = CMTimeAdd(timerange.start, timerange.duration);
                CMTime milestone = CMTimeAdd(self.audioPlayer.currentTime, CMTimeMakeWithSeconds(5.0f, timerange.duration.timescale));
                
                if (CMTIME_COMPARE_INLINE(bufferdTime , >, milestone) &&
                    self.audioPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay &&
                    !interruptedWhilePlaying &&
                    !routeChangedWhilePlaying)
                {
                    if (![self isPlaying])
                    {
                        pauseReasonBuffering = NO;
                        
                        [self.audioPlayer play];
                        [self longTimeBufferBackgroundCompleted];
                    }
                }
            }
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    AVPlayerItem *item = [notification object];
    if (![item isEqual:self.audioPlayer.currentItem]) {
        return;
    }
    
    NSNumber *currentItemIndex = [self getIndex:self.audioPlayer.currentItem];
    if (currentItemIndex) {
        if (_repeatMode == CoreMusicPlayerRepeatModeOnce)
        {
            NSInteger currentIndex = [currentItemIndex integerValue];
            [self fetchAndPlayPlayerItem:currentIndex];
        }
        else if (_shuffleMode == CoreMusicPlayerShuffleModeOn) {
            NSInteger nextIndex = [self randomIndex];
            if (nextIndex != NSNotFound) {
                [self fetchAndPlayPlayerItem:[self randomIndex]];
            }
            else {
                pauseReasonForced = YES;
                if ([self.delegate respondsToSelector:@selector(playerDidReachEnd)]) {
                    [self.delegate playerDidReachEnd];
                }
            }
        }
        else {
            if (self.audioPlayer.items.count == 1 || !isPreBuffered) {
                NSInteger nowIndex = [currentItemIndex integerValue];
                if (nowIndex + 1 < [self numberOfItems]) {
                    [self playNext];
                }
                else {
                    if (_repeatMode == CoreMusicPlayerRepeatModeOff) {
                        pauseReasonForced = YES;
                        if ([self.delegate respondsToSelector:@selector(playerDidReachEnd)]) {
                            [self.delegate playerDidReachEnd];
                        }
                    }
                    else {
                        [self fetchAndPlayPlayerItem:0];
                    }
                }
            }
        }
    }
}

- (void)playerItemFailedToPlayEndTime:(NSNotification *)notification {
    AVPlayerItem *item = [notification object];
    if (![item isEqual:self.audioPlayer.currentItem]) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(playerItemFailedToPlayEndTime:error:)]) {
        [self.delegate playerItemFailedToPlayEndTime:notification.object error:notification.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey]];
    }
}

- (void)playerItemPlaybackStall:(NSNotification *)notification {
    AVPlayerItem *item = [notification object];
    if (![item isEqual:self.audioPlayer.currentItem]) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(playerItemPlaybackStall:)]) {
        [self.delegate playerItemPlaybackStall:notification.object];
    }
}

- (NSInteger)randomIndex
{
    NSInteger itemsCount = [self numberOfItems];
    if ([self.playedItems count] == itemsCount) {
        self.playedItems = [NSMutableSet set];
        if (_repeatMode == CoreMusicPlayerRepeatModeOff) {
            return NSNotFound;
        }
    }
    
    NSInteger index;
    do {
        index = arc4random() % itemsCount;
    } while ([_playedItems containsObject:[NSNumber numberWithInteger:index]]);
    
    return index;
}

#pragma mark - Deprecation

- (void)deprecatePlayer
{
    tookAudioFocus = NO;
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    
    @try {
        [self.audioPlayer removeObserver:self forKeyPath:@"status" context:nil];
        [self.audioPlayer removeObserver:self forKeyPath:@"rate" context:nil];
        [self.audioPlayer removeObserver:self forKeyPath:@"currentItem" context:nil];
    } @catch(id anException) {}
 
    [self removeAllItems];
 
    [self.audioPlayer pause];
    self.audioPlayer = nil;
 
    self.delegate = nil;
    self.datasource = nil;
 
    routeChangedWhilePlaying = NO;
    interruptedWhilePlaying = NO;
    pauseReasonForced = NO;
    pauseReasonBuffering = NO;
    isPreBuffered = NO;
    
    onceToken = 0;
}

#pragma mark - MemoryCached

- (BOOL)isMemoryCached
{
    return self.playerItems != nil;
}

- (void)enableMemoryCached:(BOOL)memoryCache
{
    if (self.playerItems == nil && memoryCache) {
        self.playerItems = [NSArray array];
    }
    else if (self.playerItems != nil && !memoryCache) {
        self.playerItems = nil;
    }
}

- (void)removeItemFromCache:(NSInteger)index
{
    for (AVPlayerItem *item in [NSArray arrayWithArray:self.playerItems]) {
        NSInteger checkIndex = [[self getIndex:item] integerValue];
        if (checkIndex == index)
        {
            NSMutableArray *playerItems = [NSMutableArray arrayWithArray:self.playerItems];
            [playerItems removeObject:item];
            self.playerItems = playerItems;
        }
        else if (checkIndex > index) {
            [self setIndex:item key:[NSNumber numberWithInteger:checkIndex -1]];
        }
    }
}

@end

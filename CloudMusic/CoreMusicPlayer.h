//
//  MochaMusicPlayer.h
//  HyseteriaSamples
//
//  Created by TuanTN8 on 4/11/16.
//  Copyright © 2016 saiday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioSession.h>

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger,CoreMusicPlayerReadyToPlay) {
    CoreMusicPlayerReadyToPlayPlayer = 3000,
    CoreMusicPlayerReadyToPlayCurrentItem = 3001,
};

typedef NS_ENUM(NSInteger,CoreMusicPlayerFailed) {
    CoreMusicPlayerFailedPlayer = 4000,
    CoreMusicPlayerFailedCurrentItem = 4001,
};

typedef NS_ENUM(NSInteger,CoreMusicPlayerStatus) {
    CoreMusicPlayerStatusPlaying = 0,
    CoreMusicPlayerStatusForcePause,
    CoreMusicPlayerStatusBuffering,
    CoreMusicPlayerStatusUnknown,
};

typedef NS_ENUM(NSInteger,CoreMusicPlayerRepeatMode) {
    CoreMusicPlayerRepeatModeOn = 0,
    CoreMusicPlayerRepeatModeOnce,
    CoreMusicPlayerRepeatModeOff,
};

typedef NS_ENUM(NSInteger,CoreMusicPlayerShuffleMode) {
    CoreMusicPlayerShuffleModeOn = 0,
    CoreMusicPlayerShuffleModeOff,
};

@protocol CoreMusicPlayerDelegate <NSObject>

- (void)playerWillChangedAtIndex:(NSInteger)index;
- (void)playerStateChanged:(CoreMusicPlayerStatus)iStatus;
- (void)playerDidReachEnd;
- (void)playerDidFailed:(CoreMusicPlayerFailed)iStatus atIndex:(NSInteger)index;
- (void)playerReadyToPlay:(CoreMusicPlayerReadyToPlay)iStatus;

@optional

- (void)playerCurrentItemPreloaded:(CMTime)time;
- (void)playerCurrentItemChanged:(AVPlayerItem *)item;
- (void)playerItemFailedToPlayEndTime:(AVPlayerItem *)item error:(NSError *)error;
- (void)playerItemPlaybackStall:(AVPlayerItem *)item;

@end

@protocol CoreMusicPlayerDataSource <NSObject>

- (NSInteger)numberOfItems;
- (NSURL *)URLForItemAtIndex:(NSInteger)index preBuffer:(BOOL)preBuffer;

@end

@interface CoreMusicPlayer : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVQueuePlayer *audioPlayer;
@property (nonatomic, weak) id<CoreMusicPlayerDelegate> delegate;
@property (nonatomic, weak) id<CoreMusicPlayerDataSource> datasource;

@property (nonatomic) NSInteger itemsCount;
@property (nonatomic, strong, readonly) NSArray *playerItems;

+ (CoreMusicPlayer *)sharedInstance;

- (void)preAction;

- (void)setupPlayerItemWithUrl:(NSURL *)url index:(NSInteger)index;
- (void)fetchAndPlayPlayerItem: (NSInteger )startAt;
- (void)removeAllItems;
- (void)removeQueuesAtPlayer;

- (void)removeItemAtIndex:(NSInteger)index;
- (void)moveItemFromIndex:(NSInteger)from toIndex:(NSInteger)to;
- (void)play;
- (void)pause;
- (void)playPrevious;
- (void)playNext;
- (void)seekToTime:(double)CMTime;
- (void)seekToTime:(double)CMTime withCompletionBlock:(void (^)(BOOL finished))completionBlock;

- (void)setPlayerRepeatMode:(CoreMusicPlayerRepeatMode)mode;
- (CoreMusicPlayerRepeatMode)getPlayerRepeatMode;

- (void)setPlayerShuffleMode:(CoreMusicPlayerShuffleMode)mode;
- (CoreMusicPlayerShuffleMode)getPlayerShuffleMode;

- (BOOL)isPlaying;
- (CoreMusicPlayerStatus)getCoreMusicPlayerStatus;

- (float)getPlayingItemCurrentTime;
- (float)getPlayingItemDurationTime;

- (id)addBoundaryTimeObserverForTimes:(NSArray *)times queue:(dispatch_queue_t)queue usingBlock:(void (^)(void))block;
- (id)addPeriodicTimeObserverForInterval:(CMTime)interval queue:(dispatch_queue_t)queue usingBlock:(void (^)(CMTime time))block;

- (void)removeTimeObserver:(id)observer;
- (void)deprecatePlayer;

@end

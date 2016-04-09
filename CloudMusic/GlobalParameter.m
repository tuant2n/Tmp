//
//  GlobalParameter.m
//  CloudMusic
//
//  Created by TuanTN on 3/11/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "GlobalParameter.h"
#import "Utils.h"

@interface GlobalParameter()
{
    BOOL isPlayingMusic;
}

@end

@implementation GlobalParameter

static GlobalParameter *globalParameter = nil;

+ (GlobalParameter *)sharedInstance
{
    static dispatch_once_t dispatchOnce;
    
    dispatch_once(&dispatchOnce, ^{
        globalParameter = [[GlobalParameter alloc] init];
        [globalParameter initValue];
    });
    return globalParameter;
}

- (void)initValue
{
    isPlayingMusic = NO;
}

#pragma mark - Play State

- (void)startPlay
{
    isPlayingMusic = YES;
}

- (void)pausePlay
{
    isPlayingMusic = NO;
}

- (BOOL)isPlay
{
    return isPlayingMusic;
}

- (void)setCurrentPlayingItem:(Item *)itemObj
{
    if ([self.currentItemPlay isEqual:itemObj]) {
        return;
    }
    
    NSMutableDictionary *musicInfo = [[NSMutableDictionary alloc] init];
    
    if (self.currentItemPlay) {
        self.currentItemPlay.isPlaying = NO;
        [musicInfo setObject:self.currentItemPlay forKey:@"lastItem"];
    }
    
    self.currentItemPlay = itemObj;
    self.currentItemPlay.isPlaying = YES;
    [musicInfo setObject:self.currentItemPlay forKey:@"currentItem"];
    [self startPlay];
}

#pragma mark - DropBoxInfo

- (void)clearDropBoxInfo
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"DROPBOX_NAME"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"DROPBOX_ID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setDropBoxName:(NSString *)sName
{
    [[NSUserDefaults standardUserDefaults] setObject:sName forKey:@"DROPBOX_NAME"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getDropBoxName
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"DROPBOX_NAME"];
}

- (void)setDropBoxId:(NSString *)sId
{
    [[NSUserDefaults standardUserDefaults] setObject:sId forKey:@"DROPBOX_ID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getDropBoxId
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"DROPBOX_ID"];
}

@end

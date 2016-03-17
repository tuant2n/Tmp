//
//  GlobalParameter.m
//  CloudMusic
//
//  Created by TuanTN on 3/11/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "GlobalParameter.h"

#import "SongObject.h"

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
    
    _arrListSong = [[NSMutableArray alloc] init];
    _arrData = [[NSMutableArray alloc] init];
}

#pragma mark - Data

- (void)setupData
{
    [self.arrListSong removeAllObjects];
    NSArray *dataFromDB = [self readData];
    if (dataFromDB) {
        [self.arrData addObjectsFromArray:dataFromDB];
    }
 
    [self.arrListSong removeAllObjects];
    for (NSDictionary *songInfo in self.arrData) {
        SongObject *songObj = [[SongObject alloc] initWithInfo:songInfo];
        [self.arrListSong addObject:songObj];
    }
    
    NSSet *uniqueAlbumId = [NSSet setWithArray:[self.arrListSong valueForKey:@"iAlbumId"]];
    NSMutableArray *listAlbumId = [[NSMutableArray alloc] initWithArray:[uniqueAlbumId allObjects]];
    NSLog(@"%@",listAlbumId);
    
    NSSet *uniqueArtistId = [NSSet setWithArray:[self.arrListSong valueForKey:@"iArtistPID"]];
    NSMutableArray *listArtistId = [[NSMutableArray alloc] initWithArray:[uniqueArtistId allObjects]];
    NSLog(@"%@",listArtistId);
    
    NSSet *uniqueGenreId = [NSSet setWithArray:[self.arrListSong valueForKey:@"iGenreId"]];
    NSMutableArray *listGenreId = [[NSMutableArray alloc] initWithArray:[uniqueGenreId allObjects]];
    NSLog(@"%@",listGenreId);
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

#pragma mark - iTunes Sync

- (void)setLastTimeAppSync:(long)lTime
{
    [[NSUserDefaults standardUserDefaults] setInteger:lTime forKey:@"LASTTIME_APP_SYNC"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (long)lastTimeAppSync
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"LASTTIME_APP_SYNC"];
}

#pragma mark - Save Data

- (void)saveData:(NSArray *)listSong
{
    NSString *dataPath = [[Utils documentPath] stringByAppendingPathComponent:@"Data.plist"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:listSong];
    [data writeToFile:dataPath atomically:YES];
}

- (NSArray *)readData
{
    NSString *dataPath = [[Utils documentPath] stringByAppendingPathComponent:@"Data.plist"];
    NSData *data = [NSData dataWithContentsOfFile:dataPath];
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

@end

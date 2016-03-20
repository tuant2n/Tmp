//
//  GlobalParameter.m
//  CloudMusic
//
//  Created by TuanTN on 3/11/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "GlobalParameter.h"

#import "SongObject.h"
#import "AlbumObject.h"
#import "ArtistObject.h"
#import "GenreObject.h"

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
    
    _arrData = [[NSMutableArray alloc] init];
    _arrListSong = [[NSMutableArray alloc] init];
    _arrListAlbum = [[NSMutableArray alloc] init];
    _arrListArtist = [[NSMutableArray alloc] init];
    _arrListGenre = [[NSMutableArray alloc] init];
}

#pragma mark - Data

- (void)setupData
{
    [self.arrListSong removeAllObjects];
    [self.arrListSong removeAllObjects];
    [self.arrListAlbum removeAllObjects];
    [self.arrListArtist removeAllObjects];
    
    NSArray *dataFromDB = [self readData];
    if (!dataFromDB) {
        return;
    }
    [self.arrData addObjectsFromArray:dataFromDB];
    
    for (NSDictionary *songInfo in self.arrData)
    {
        SongObject *songObj = [[SongObject alloc] initWithInfo:songInfo];
        [self.arrListSong addObject:songObj];
    }
    
    NSPredicate *predicate = nil;
    NSArray *tmpList = nil;
    
    NSSet *uniqueAlbumId = [NSSet setWithArray:[self.arrListSong valueForKey:@"iAlbumId"]];
    NSMutableArray *listAlbumId = [[NSMutableArray alloc] initWithArray:[uniqueAlbumId allObjects]];
    for (NSString *sAlbumId in listAlbumId)
    {
        predicate = [NSPredicate predicateWithFormat:@"iAlbumId == %@", sAlbumId];
        tmpList = [self.arrListSong filteredArrayUsingPredicate:predicate];
        
        NSDictionary *albumInfo = [[self.arrData filteredArrayUsingPredicate:predicate] firstObject];
        AlbumObject *albumObj = [[AlbumObject alloc] initWithInfo:albumInfo];
        albumObj.listSong = tmpList;
        
        albumObj.iTrackCount = (int)albumObj.listSong.count;
        albumObj.fDuration = [[albumObj.listSong valueForKeyPath:@"@sum.fDuration"] floatValue];
        NSString *sTime = [Utils timeFormattedForList:albumObj.fDuration];
        
        NSString *sDesc = [NSString stringWithFormat:@"%d Songs, %@",albumObj.iTrackCount,sTime];
        albumObj.sDescription = sDesc;
        
        [self.arrListAlbum addObject:albumObj];
    }
    
    //
    NSSet *uniqueArtistId = [NSSet setWithArray:[self.arrListSong valueForKey:@"iArtistId"]];
    NSMutableArray *listArtistId = [[NSMutableArray alloc] initWithArray:[uniqueArtistId allObjects]];
    for (NSString *sArtistId in listArtistId) {
        predicate = [NSPredicate predicateWithFormat:@"iArtistId == %@", sArtistId];
        tmpList = [self.arrListSong filteredArrayUsingPredicate:predicate];
        
        NSDictionary *albumInfo = [[self.arrData filteredArrayUsingPredicate:predicate] firstObject];
        ArtistObject *artistObj = [[ArtistObject alloc] initWithInfo:albumInfo];
        artistObj.listSong = tmpList;
        
        artistObj.iTrackCount = (int)artistObj.listSong.count;
        artistObj.fDuration = [[artistObj.listSong valueForKeyPath:@"@sum.fDuration"] floatValue];
        NSString *sTime = [Utils timeFormattedForList:artistObj.fDuration];
        
        NSString *sDesc = [NSString stringWithFormat:@"%d Songs, %@",artistObj.iTrackCount,sTime];
        artistObj.sDescription = sDesc;
        
        [self.arrListArtist addObject:artistObj];
        NSLog(@"%@",artistObj.sArtist);
    }
    
    //
    NSSet *uniqueGenreId = [NSSet setWithArray:[self.arrListSong valueForKey:@"iGenreId"]];
    NSMutableArray *listGenreId = [[NSMutableArray alloc] initWithArray:[uniqueGenreId allObjects]];
    for (NSString *sGenreId in listGenreId) {
        predicate = [NSPredicate predicateWithFormat:@"iGenreId == %@", sGenreId];
        tmpList = [self.arrListSong filteredArrayUsingPredicate:predicate];
        
        NSDictionary *albumInfo = [[self.arrData filteredArrayUsingPredicate:predicate] firstObject];
        GenreObject *genreObj = [[GenreObject alloc] initWithInfo:albumInfo];
        genreObj.listSong = tmpList;
        
        genreObj.iTrackCount = (int)genreObj.listSong.count;
        genreObj.fDuration = [[genreObj.listSong valueForKeyPath:@"@sum.fDuration"] floatValue];
        NSString *sTime = [Utils timeFormattedForList:genreObj.fDuration];
        
        NSString *sDesc = [NSString stringWithFormat:@"%d Songs, %@",genreObj.iTrackCount,sTime];
        genreObj.sDescription = sDesc;
        
        [self.arrListGenre addObject:genreObj];
    }
    
    NSLog(@"SONG: %d",(int)self.arrListSong.count);
    NSLog(@"ALBUM: %d",(int)self.arrListAlbum.count);
    NSLog(@"ARTIST: %d",(int)self.arrListArtist.count);
    NSLog(@"GENRE: %d",(int)self.arrListGenre.count);
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

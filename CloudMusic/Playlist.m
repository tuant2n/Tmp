//
//  Playlist.m
//  CloudMusic
//
//  Created by TuanTN on 4/18/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "Playlist.h"

#import "Item.h"

#import "Utils.h"

@implementation Playlist

@synthesize sLocalArtworkUrl;
@synthesize sPlaylistDesc;

- (void)setPlaylist:(NSArray *)listSong
{
    sPlaylistDesc = nil;
    self.listSong = [NSKeyedArchiver archivedDataWithRootObject:listSong];
}

- (NSArray *)getPlaylist
{
    if (self.listSong) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:self.listSong];
    }
    return nil;
}

- (NSString *)sPlaylistDesc
{
    if (!sPlaylistDesc)
    {
        NSArray *songList = [self getPlaylist];
        int numberOfSong = (int)songList.count;
        
        NSString *sSongs = nil;
        
        if (numberOfSong <= 1) {
            sSongs = @"Song";[NSString stringWithFormat:@"%d Song",numberOfSong];
        }
        else {
            sSongs = @"Songs";[NSString stringWithFormat:@"%d Songs",numberOfSong];
        }

        sPlaylistDesc = [NSString stringWithFormat:@"%d %@, %@",numberOfSong,sSongs,[Utils timeFormattedForList:[self.fDuration intValue]]];
    }
    return sPlaylistDesc;
}

- (void)setArtwork:(NSString *)sArtworkName
{
    self.sArtworkName = sArtworkName;
    sLocalArtworkUrl = nil;
}

- (NSURL *)sLocalArtworkUrl
{
    if (!sLocalArtworkUrl && self.sArtworkName) {
        sLocalArtworkUrl = [NSURL fileURLWithPath:[[Utils artworkPath] stringByAppendingPathComponent:self.sArtworkName]];
    }
    return sLocalArtworkUrl;
}

#pragma mark - Method

- (void)addSongs:(NSArray *)listNewSong
{
    NSMutableArray *listSong = [[NSMutableArray alloc] initWithArray:[self getPlaylist]];
    int fDuration = [self.fDuration intValue];
    
    for (Item *newSong in listNewSong) {
        [listSong insertObject:newSong.iSongId atIndex:0];
        fDuration += [newSong.fDuration intValue];
        
        if (newSong.sArtworkName) {
            [self setArtwork:newSong.sArtworkName];
        }
    }
    
    if (fDuration > 0) {
        self.fDuration = @(fDuration);
    }
    
    [self setPlaylist:listSong];
}


@end

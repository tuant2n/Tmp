//
//  SongObject.m
//  CloudMusic
//
//  Created by TuanTN on 3/17/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "SongObject.h"

#import "Utils.h"

@implementation SongObject

- (id)initWithInfo:(NSDictionary *)songInfo
{
    self = [super init];
    
    if (self) {
        _iSongId = [songInfo objectForKey:@"iSongId"];
        _sSongTitle = [songInfo objectForKey:@"sSongTitle"];
        _sAssetUrl = [songInfo objectForKey:@"sAssetUrl"];
        _isDownloaded = [[songInfo objectForKey:@"isDownloaded"] boolValue];
        
        NSString *sArtworkName = [songInfo objectForKey:@"sArtworkName"];
        if (sArtworkName) {
            NSString *sArtworkPath = [[Utils artworkPath] stringByAppendingPathComponent:sArtworkName];
            _imgArtwork = [UIImage imageWithContentsOfFile:sArtworkPath];
        }
        
        _lPlayCount = [[songInfo objectForKey:@"iPlayCount"] longValue];
        _iRating = [[songInfo objectForKey:@"iRating"] intValue];
        _fDuration = [[songInfo objectForKey:@"fDuration"] floatValue];
        _iTrack = [[songInfo objectForKey:@"iTrack"] intValue];
        
        _sLyrics = [songInfo objectForKey:@"sLyrics"];
        _iYear = [[songInfo objectForKey:@"iYear"] intValue];
        
        _iArtistPID = [songInfo objectForKey:@"iArtistId"];
        _sArtist = [songInfo objectForKey:@"sArtist"];
        
        _iAlbumId = [songInfo objectForKey:@"iAlbumId"];
        _sAlbumTitle = [songInfo objectForKey:@"sAlbumTitle"];
        
        _iGenreId = [songInfo objectForKey:@"iGenreId"];
        _sGenre = [songInfo objectForKey:@"sGenre"];
        
        _iGenreId = [songInfo objectForKey:@"iGenreId"];
        _sGenre = [songInfo objectForKey:@"sGenre"];
        
        _iAlbumArtistId = [songInfo objectForKey:@"iAlbumArtistId"];
        _sAlbumArtist = [songInfo objectForKey:@"sAlbumArtist"];
    }
    
    return self;
}

@end

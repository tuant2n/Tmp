//
//  Item.m
//  CloudMusic
//
//  Created by TuanTN on 3/20/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "Item.h"

#import "MPMediaItem+Accessors.h"
#import "Utils.h"

@implementation Item

/*
 @property (nullable, nonatomic, retain) NSNumber *iPlaylistId;
 @property (nullable, nonatomic, retain) NSString *sPlaylistName;
 */

- (void)updateWithMediaItem:(MPMediaItem *)item
{
    self.sAssetUrl = [item.itemAssetURL absoluteString];
    self.iType = [NSNumber numberWithInt:kSourceTypeCloud];
    
    self.iSongId = item.itemPersistentID;
    [self setSongName:item.itemTitle];
    
    self.iAlbumId = item.itemAlbumPID;
    [self setAlbumName:item.itemAlbumTitle];
    
    self.iArtistId = item.itemArtistPID;
    self.sArtistName = item.itemArtist;
    
    self.iGenreId = item.itemGenrePID;
    self.sGenreName = item.itemGenre;
    
    UIImage *artwork = [item.itemArtwork imageWithSize:item.itemArtwork.bounds.size];
    if (artwork) {
        NSString *sArtworkName = [NSString stringWithFormat:@"%@.png",self.iSongId];
        BOOL isSaveArtwork = [UIImagePNGRepresentation(artwork) writeToFile:[[Utils artworkPath] stringByAppendingPathComponent:sArtworkName] atomically:YES];
        
        if (isSaveArtwork) {
            self.sArworkName = sArtworkName;
        }
    }
    
    self.sLyrics = item.itemLyrics;
    self.iRate = item.itemRating;
    self.iTrack = item.itemAlbumTrackNumber;
    self.iPlayCount = item.itemPlayCount;
    self.fDuration = item.itemPlaybackDuration;
}

- (void)setSongName:(NSString *)sSongName
{
    self.sSongName = sSongName;
    self.sSongNameIndex = [[Utils standardLocaleString:self.sSongName] lowercaseString];
    
    NSString *sFirstLetter = [[self.sSongNameIndex substringToIndex:1] uppercaseString];
    if (![Utils isAlphanumbericLetter:sFirstLetter]) {
        sFirstLetter = @"#";
    }
    self.sSongFirstLetter = sFirstLetter;
}

- (void)setAlbumName:(NSString *)sAlbumName
{
    self.sAlbumName = sAlbumName;
    self.sAlbumName = [[Utils standardLocaleString:self.sAlbumName] lowercaseString];
}

@end

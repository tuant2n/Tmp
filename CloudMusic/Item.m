//
//  Item.m
//  CloudMusic
//
//  Created by TuanTN on 3/20/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "Item.h"

#import "Utils.h"

#import "NSAttributedString+CCLFormat.h"
#import "MPMediaItem+Accessors.h"

@implementation Item

@synthesize isPlaying;

@synthesize isCloud;
@synthesize sLocalArtworkUrl;
@synthesize sSongDesc;

/*
 @property (nullable, nonatomic, retain) NSNumber *iPlaylistId;
 @property (nullable, nonatomic, retain) NSString *sPlaylistName;
 */

- (void)updateWithMediaItem:(MPMediaItem *)item
{
    self.sAssetUrl = [item.itemAssetURL absoluteString];

    self.iSongId = [item.itemPersistentID stringValue];
    [self setSongName:item.itemTitle];
    
    self.iAlbumId = [NSString stringWithFormat:@"%@ - %@",[item.itemAlbumPID stringValue],[item.year stringValue]];
    [self setAlbumName:item.itemAlbumTitle];
    
    self.iArtistId = [item.itemArtistPID stringValue];
    [self setArtistName:item.itemArtist];
    
    self.iAlbumArtistId = [item.itemAlbumArtistPID stringValue];
    [self setAlbumArtistName:item.itemAlbumArtist];
    
    self.iGenreId = [item.itemGenrePID stringValue];
    [self setGenreName:item.itemGenre];
    
    UIImage *artwork = [item.itemArtwork imageWithSize:item.itemArtwork.bounds.size];
    if (artwork) {
        NSString *sArtworkName = [NSString stringWithFormat:@"%@.png",self.iSongId];
        BOOL isSaveArtwork = [UIImagePNGRepresentation(artwork) writeToFile:[[Utils artworkPath] stringByAppendingPathComponent:sArtworkName] atomically:YES];
        if (isSaveArtwork) {
            self.sArtworkName = sArtworkName;
        }
    }
    
    self.sLyrics = item.itemLyrics;
    self.iYear = item.year;
    self.iRate = item.itemRating;
    self.iTrack = item.itemAlbumTrackNumber;
    self.iPlayCount = item.itemPlayCount;
    
    [self setSongDuration:item.playbackDuration];
    
    if ([item.itemTitle hasPrefix:@"Mùa"]) {
        self.iCloud = @1;
    }
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
    self.sAlbumNameIndex = [[Utils standardLocaleString:self.sAlbumName] lowercaseString];
}

- (void)setArtistName:(NSString *)sArtistName
{
    self.sArtistName = sArtistName;
    self.sArtistNameIndex = [[Utils standardLocaleString:self.sArtistName] lowercaseString];
}

- (void)setAlbumArtistName:(NSString *)sAlbumArtistName
{
    self.sAlbumArtistName = sAlbumArtistName;
    self.sAlbumArtistNameIndex = [[Utils standardLocaleString:self.sAlbumArtistName] lowercaseString];
}

- (void)setGenreName:(NSString *)sGenreName
{
    self.sGenreName = sGenreName;
    self.sGenreNameIndex = [[Utils standardLocaleString:self.sGenreName] lowercaseString];
}

- (void)setSongDuration:(int)fDuration
{
    self.fDuration = [NSNumber numberWithInt:fDuration];
    self.sDuration = [Utils timeFormattedForSong:fDuration];
}

- (NSURL *)sLocalArtworkUrl
{
    if (!sLocalArtworkUrl && self.sArtworkName) {
        sLocalArtworkUrl = [NSURL fileURLWithPath:[[Utils artworkPath] stringByAppendingPathComponent:self.sArtworkName]];
    }
    return sLocalArtworkUrl;
}

- (NSAttributedString *)sSongDesc
{
    if (!sSongDesc)
    {
        NSAttributedString *sArtist = nil;
        if (self.sArtistName) {
            sArtist = [[NSAttributedString alloc] initWithString:self.sArtistName
                                                      attributes:@{
                                      NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0],
                                      NSForegroundColorAttributeName:[UIColor blackColor],
                                      }];
        }
        
        NSAttributedString *sAlbumName = nil;
        if (self.sAlbumName)
        {
            sAlbumName = [[NSAttributedString alloc] initWithString:self.sAlbumName
                                                         attributes:@{
                         NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:14.0],
                         NSForegroundColorAttributeName:[Utils colorWithRGBHex:0x6a6a6a],
                         }];
        }
        
        if (sArtist) {
            if (sAlbumName) {
                sSongDesc = [NSAttributedString attributedStringWithFormat:@"%@ %@",sArtist,sAlbumName];
            }
            else {
                sSongDesc = sArtist;
            }
        }
        else {
            if (sAlbumName) {
                sSongDesc = sAlbumName;
            }
            else {
                sSongDesc = [NSAttributedString attributedStringWithFormat:@""];
            }
        }
        
    }
    return sSongDesc;
}

- (BOOL)isCloud
{
    return [self.iCloud intValue] == 1;
}

@end

//
//  Item.m
//  CloudMusic
//
//  Created by TuanTN on 3/20/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "Item.h"

#import "File.h"
#import "DropBoxObj.h"

#import "DataManagement.h"
#import "Utils.h"

#import "NSAttributedString+CCLFormat.h"
#import "MPMediaItem+Accessors.h"

@implementation Item

@synthesize isCloud;
@synthesize sLocalArtworkUrl;

@synthesize sSongDesc;
@synthesize sSongPlayerDesc;

@synthesize sPlayableUrl;

@synthesize numberOfSelect;
@synthesize isPlaying;

#pragma mark - Update Item

- (void)updateWithMediaItem:(MPMediaItem *)item
{
    self.sAssetUrl = [item.itemAssetURL absoluteString];
    self.sLyrics = item.itemLyrics;
    self.iYear = item.year;
    self.iRate = item.itemRating;
    self.iPlayCount = item.itemPlayCount;
    
    self.iSongId = [item.itemPersistentID stringValue];
    [self setSongName:item.itemTitle];
    
    self.iAlbumId = [NSString stringWithFormat:@"%@-%@",[item.itemAlbumPID stringValue],[item.year stringValue]];
    [self updateAlbumName:item.itemAlbumTitle];
    
    self.iArtistId = [item.itemArtistPID stringValue];
    [self changeArtistName:item.itemArtist];
    
    self.iAlbumArtistId = [item.itemAlbumArtistPID stringValue];
    [self updateAlbumArtistName:item.itemAlbumArtist];
    
    self.iGenreId = [item.itemGenrePID stringValue];
    [self updateGenreName:item.itemGenre];
    
    UIImage *artwork = [item.itemArtwork imageWithSize:item.itemArtwork.bounds.size];
    if (artwork) {
        [self setArtwork:artwork];
    }
    
    [self setSongDuration:item.playbackDuration];
}

- (void)updateWithSongUrl:(NSURL *)songUrl songInfo:(NSDictionary *)songInfo
{
    self.iSongId = [Utils getTimestamp];
    self.iCloudItem = @1;
    self.sAssetUrl = [songUrl.path lastPathComponent];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:songUrl options:nil];
    [self setSongDuration:CMTimeGetSeconds([asset duration])];
    
    NSString *sYear = [songInfo objectForKey:@"year"];
    if (sYear) {
        self.iYear = @([sYear integerValue]);
    }
    
    NSString *sLyrics = [songInfo objectForKey:@"lyrics"];
    if (sLyrics) {
        self.sLyrics = sLyrics;
    }
    
    UIImage *artwork = [songInfo objectForKey:@"artwork"];
    if (artwork && [artwork isKindOfClass:[UIImage class]]) {
        [self setArtwork:artwork];
    }
    
    NSString *sTitle = [songInfo objectForKey:@"title"];
    if (sTitle) {
        [self setSongName:sTitle];
    }
    
    NSString *sAlbumName = [songInfo objectForKey:@"album"];
    if (sAlbumName)
    {
        NSString *iAlbumId = [[DataManagement sharedInstance] getAlbumIdFromName:sAlbumName year:[self.iYear intValue]];
        if (iAlbumId) {
            self.iAlbumId = iAlbumId;
        }
        else {
            self.iAlbumId = [NSString stringWithFormat:@"%@-%@",sAlbumName,self.iSongId];
        }
        
        [self setAlbumName:sAlbumName];
    }
    
    NSString *sArtistName = [songInfo objectForKey:@"artist"];
    if (sArtistName)
    {
        NSString *iArtistId = [[DataManagement sharedInstance] getArtistIdFromName:sArtistName];
        if (iArtistId) {
            self.iArtistId = iArtistId;
        }
        else {
            self.iArtistId = [NSString stringWithFormat:@"%@-%@",sArtistName,self.iSongId];
        }
        
        [self setArtistName:sArtistName];
        
        
        NSString *iAlbumArtistId = [[DataManagement sharedInstance] getAlbumArtistIdFromName:sArtistName];
        if (iAlbumArtistId) {
            self.iAlbumArtistId = iAlbumArtistId;
        }
        else {
            self.iAlbumArtistId = [NSString stringWithFormat:@"%@-%@",sArtistName,self.iSongId];
        }
        [self setAlbumArtistName:sArtistName];
    }
    
    NSString *sGenreName = [songInfo objectForKey:@"genre"];
    if (sGenreName) {
        NSString *iGenreId = [[DataManagement sharedInstance] getGenreIdFromName:sGenreName];
        if (iGenreId) {
            self.iGenreId = iGenreId;
        }
        else {
            self.iGenreId = [NSString stringWithFormat:@"%@-%@",sGenreName,self.iSongId];
        }
        [self setGenreName:sGenreName];
    }
}

#pragma mark - Name

- (void)setSongName:(NSString *)sSongName
{
    if (sSongName.length <= 0) {
        return;
    }
    
    self.sSongName = sSongName;
    self.sSongNameIndex = [[Utils standardLocaleString:self.sSongName] lowercaseString];
    
    NSString *sFirstLetter = [[self.sSongNameIndex substringToIndex:1] uppercaseString];
    if (![Utils isAlphanumbericLetter:sFirstLetter]) {
        sFirstLetter = @"#";
    }
    self.sSongFirstLetter = sFirstLetter;
}

#pragma mark - Album

- (void)setAlbumName:(NSString *)sAlbumName
{
    self.sAlbumName = sAlbumName;
    self.sAlbumNameIndex = [[Utils standardLocaleString:self.sAlbumName] lowercaseString];
}

- (void)changeAlbumName:(NSString *)sAlbumName
{
    if (sAlbumName.length <= 0) {
        return;
    }
    
    if ([self.sAlbumName isEqualToString:sAlbumName]) {
        return;
    }
    
    NSString *iAlbumId = [[DataManagement sharedInstance] getAlbumIdFromName:sAlbumName year:[self.iYear intValue]];
    if (iAlbumId) {
        self.iAlbumId = iAlbumId;
    }
    else {
        self.iAlbumId = [NSString stringWithFormat:@"%@-%@",self.iAlbumId,[Utils getTimestamp]];
    }
    
    sSongDesc = nil;
    [self setAlbumName:sAlbumName];
}

- (void)updateAlbumName:(NSString *)sAlbumName
{
    if (sAlbumName.length <= 0) {
        return;
    }
    
    if ([self.sAlbumName isEqualToString:sAlbumName]) {
        return;
    }
    
    if (![[DataManagement sharedInstance] hasAlbum:self.iAlbumId]) {
        NSString *iAlbumId = [[DataManagement sharedInstance] getAlbumIdFromName:sAlbumName year:[self.iYear intValue]];
        if (iAlbumId) {
            self.iAlbumId = iAlbumId;
        }
        else {
            self.iAlbumId = [NSString stringWithFormat:@"%@-%@",self.iAlbumId,[Utils getTimestamp]];
        }
    }

    sSongDesc = nil;
    [self setAlbumName:sAlbumName];
}

#pragma mark - Artist

- (void)setArtistName:(NSString *)sArtistName
{
    if (sArtistName.length <= 0) {
        return;
    }
    
    self.sArtistName = sArtistName;
    self.sArtistNameIndex = [[Utils standardLocaleString:self.sArtistName] lowercaseString];
}

- (void)changeArtistName:(NSString *)sArtistName
{
    if (sArtistName.length <= 0) {
        return;
    }
    
    if ([self.sArtistName isEqualToString:sArtistName]) {
        return;
    }
    
    NSString *iArtistId = [[DataManagement sharedInstance] getArtistIdFromName:sArtistName];
    if (iArtistId) {
        self.iArtistId = iArtistId;
    }
    else {
        self.iArtistId = [NSString stringWithFormat:@"%@-%@",self.iArtistId,[Utils getTimestamp]];
    }
    
    sSongDesc = nil;
    [self setArtistName:sArtistName];
}

#pragma mark - AlbumArtist

- (void)setAlbumArtistName:(NSString *)sAlbumArtistName
{
    if (sAlbumArtistName.length <= 0) {
        return;
    }
    
    sSongDesc = nil;
    self.sAlbumArtistName = sAlbumArtistName;
    self.sAlbumArtistNameIndex = [[Utils standardLocaleString:self.sAlbumArtistName] lowercaseString];
}

- (void)changeAlbumArtistName:(NSString *)sAlbumArtistName
{
    if (sAlbumArtistName.length <= 0) {
        return;
    }
    
    if ([self.sAlbumArtistName isEqualToString:sAlbumArtistName]) {
        return;
    }
    
    NSString *iAlbumArtistId = [[DataManagement sharedInstance] getAlbumArtistIdFromName:sAlbumArtistName];
    if (iAlbumArtistId) {
        self.iAlbumArtistId = iAlbumArtistId;
    }
    else {
        self.iAlbumArtistId = [NSString stringWithFormat:@"%@-%@",self.iAlbumArtistId,[Utils getTimestamp]];
    }
    
    [self setAlbumArtistName:sAlbumArtistName];
}

- (void)updateAlbumArtistName:(NSString *)sAlbumArtistName
{
    if (sAlbumArtistName.length <= 0) {
        return;
    }
    
    if ([self.sAlbumArtistName isEqualToString:sAlbumArtistName]) {
        return;
    }
    
    if (![[DataManagement sharedInstance] hasAlbumArtist:self.iAlbumArtistId]) {
        NSString *iAlbumArtistId = [[DataManagement sharedInstance] getAlbumArtistIdFromName:sAlbumArtistName];
        if (iAlbumArtistId) {
            self.iAlbumArtistId = iAlbumArtistId;
        }
        else {
            self.iAlbumArtistId = [NSString stringWithFormat:@"%@-%@",self.iAlbumArtistId,[Utils getTimestamp]];
        }
    }
    
    [self setAlbumArtistName:sAlbumArtistName];
}

#pragma mark - Genre

- (void)setGenreName:(NSString *)sGenreName
{
    if (sGenreName.length <= 0) {
        return;
    }
    
    self.sGenreName = sGenreName;
    self.sGenreNameIndex = [[Utils standardLocaleString:self.sGenreName] lowercaseString];
}

- (void)changeGenreName:(NSString *)sGenreName
{
    if (sGenreName.length <= 0) {
        return;
    }
    
    if ([self.sGenreName isEqualToString:sGenreName]) {
        return;
    }
    
    NSString *iGenreId = [[DataManagement sharedInstance] getGenreIdFromName:sGenreName];
    if (iGenreId) {
        self.iGenreId = iGenreId;
    }
    else {
        self.iGenreId = [NSString stringWithFormat:@"%@-%@",self.iGenreId,[Utils getTimestamp]];
    }
    
    [self setGenreName:sGenreName];
}

- (void)updateGenreName:(NSString *)sGenreName
{
    if (sGenreName.length <= 0) {
        return;
    }
    
    if ([self.sGenreName isEqualToString:sGenreName]) {
        return;
    }
    
    if (![[DataManagement sharedInstance] hasGenre:self.iGenreId]) {
        NSString *iGenreId = [[DataManagement sharedInstance] getGenreIdFromName:sGenreName];
        if (iGenreId) {
            self.iGenreId = iGenreId;
        }
        else {
            self.iGenreId = [NSString stringWithFormat:@"%@-%@",self.iGenreId,[Utils getTimestamp]];
        }
    }

    [self setGenreName:sGenreName];
}

#pragma mark - Artwork

- (void)setArtwork:(UIImage *)artwork
{
    NSString *sArtworkName = [NSString stringWithFormat:@"%@-%@.png",self.iSongId,[Utils getTimestamp]];
    BOOL isSaveArtwork = [UIImagePNGRepresentation(artwork) writeToFile:[[Utils artworkPath] stringByAppendingPathComponent:sArtworkName] atomically:YES];
    if (isSaveArtwork) {
        self.sArtworkName = sArtworkName;
        sLocalArtworkUrl = nil;
    }
}

- (NSURL *)sLocalArtworkUrl
{
    if (!sLocalArtworkUrl && self.sArtworkName) {
        sLocalArtworkUrl = [NSURL fileURLWithPath:[[Utils artworkPath] stringByAppendingPathComponent:self.sArtworkName]];
    }
    return sLocalArtworkUrl;
}

#pragma mark - Other

- (NSURL *)sPlayableUrl
{
    if (!sPlayableUrl) {
        if (self.isCloud) {
            sPlayableUrl = [NSURL fileURLWithPath:[[Utils dropboxPath] stringByAppendingPathComponent:self.sAssetUrl]];
        }
        else {
            sPlayableUrl = [NSURL URLWithString:self.sAssetUrl];
        }
    }
    return sPlayableUrl;
}

- (NSAttributedString *)sSongDesc
{
    if (!sSongDesc)
    {
        NSAttributedString *sArtist = nil;
        if (self.sArtistName) {
            sArtist = [[NSAttributedString alloc] initWithString:self.sArtistName attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0],NSForegroundColorAttributeName:[UIColor blackColor]}];
        }
        
        NSAttributedString *sAlbumName = nil;
        if (self.sAlbumName)
        {
            sAlbumName = [[NSAttributedString alloc] initWithString:self.sAlbumName attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:14.0],NSForegroundColorAttributeName:[Utils colorWithRGBHex:0x6a6a6a],}];
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

- (NSString *)sSongPlayerDesc
{
    if (!sSongPlayerDesc)
    {
        NSString *sArtist = self.sArtistName;
        NSString *sAlbumName = self.sAlbumName;
        
        if (sArtist) {
            if (sAlbumName) {
                sSongPlayerDesc = [NSString stringWithFormat:@"%@ - %@",sArtist,sAlbumName];
            }
            else {
                sSongPlayerDesc = sArtist;
            }
        }
        else {
            if (sAlbumName) {
                sSongPlayerDesc = sAlbumName;
            }
            else {
                sSongPlayerDesc = @"n/a";
            }
        }
    }
    return sSongPlayerDesc;
}

- (void)setSongDuration:(int)fDuration
{
    self.fDuration = [NSNumber numberWithInt:fDuration];
    self.sDuration = [Utils timeFormattedForSong:fDuration];
}

- (BOOL)isCloud
{
    return [self.iCloudItem intValue] == 1;
}

#pragma mark - Utils

- (NSArray *)getMetaData
{
    NSString *sTitle = self.sSongName;
    NSString *sAlbumName = self.sAlbumName;
    NSString *sArtistName = self.sAlbumArtistName;
    NSString *sGenre = self.sGenreName;
    NSString *sYear = [self.iYear stringValue];
    NSString *sLyrics = self.sLyrics;
    UIImage *artwork = [UIImage imageWithContentsOfFile:[self.sLocalArtworkUrl path]];
    
    NSMutableArray *metadata = [[NSMutableArray alloc] init];
    
    if (sTitle)
    {
        AVMutableMetadataItem *item = [[AVMutableMetadataItem alloc] init];
        item.locale = [NSLocale currentLocale];
        item.keySpace = AVMetadataKeySpaceCommon;
        item.key = AVMetadataCommonKeyTitle;
        item.value = sTitle;
        [metadata addObject:item];
    }
    
    if (sAlbumName) {
        AVMutableMetadataItem *item = [[AVMutableMetadataItem alloc] init];
        item.locale = [NSLocale currentLocale];
        item.keySpace = AVMetadataKeySpaceCommon;
        item.key = AVMetadataCommonKeyAlbumName;
        item.value = sAlbumName;
        [metadata addObject:item];
    }
    
    if (sArtistName) {
        AVMutableMetadataItem *item = [[AVMutableMetadataItem alloc] init];
        item.locale = [NSLocale currentLocale];
        item.keySpace = AVMetadataKeySpaceCommon;
        item.key = AVMetadataCommonKeyArtist;
        item.value = sArtistName;
        [metadata addObject:item];
    }
    
    if (sGenre) {
        AVMutableMetadataItem *itemCommon = [[AVMutableMetadataItem alloc] init];
        itemCommon.locale = [NSLocale currentLocale];
        itemCommon.keySpace = AVMetadataKeySpaceCommon;
        itemCommon.key = AVMetadataCommonKeyType;
        itemCommon.value = sGenre;
        [metadata addObject:itemCommon];
        
        AVMutableMetadataItem *userGenre = [[AVMutableMetadataItem alloc] init];
        userGenre.locale = [NSLocale currentLocale];
        userGenre.keySpace = AVMetadataKeySpaceiTunes;
        userGenre.key = AVMetadataiTunesMetadataKeyUserGenre;
        userGenre.value = sGenre;
        [metadata addObject:userGenre];
    }
    
    if (sYear) {
        AVMutableMetadataItem *item = [[AVMutableMetadataItem alloc] init];
        item.locale = [NSLocale currentLocale];
        item.keySpace = AVMetadataKeySpaceCommon;
        item.key = AVMetadataCommonKeyCreationDate;
        item.value = sYear;
        [metadata addObject:item];
    }
    
    if (artwork) {
        AVMutableMetadataItem *item = [[AVMutableMetadataItem alloc] init];
        item.locale = [NSLocale currentLocale];
        item.keySpace = AVMetadataKeySpaceCommon;
        item.key = AVMetadataCommonKeyArtwork;
        item.dataType = (__bridge NSString * _Nullable)(kCMMetadataBaseDataType_PNG);
        item.value = UIImagePNGRepresentation(artwork);
        [metadata addObject:item];
    }
    
    if (sLyrics) {
        AVMutableMetadataItem *item = [[AVMutableMetadataItem alloc] init];
        item.locale = [NSLocale currentLocale];
        item.keySpace = AVMetadataKeySpaceiTunes;
        item.key = AVMetadataiTunesMetadataKeyLyrics;
        item.value = sLyrics;
        [metadata addObject:item];
    }
    
    return [metadata copy];
}

@end

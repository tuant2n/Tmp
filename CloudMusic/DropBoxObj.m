//
//  DropBoxObj.m
//  CloudMusic
//
//  Created by TuanTN on 4/9/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "DropBoxObj.h"

#import "Utils.h"

@implementation DropBoxObj

- (id)initWithMetadata:(DBMetadata *)metadata
{
    self = [self init];
    
    if (self)
    {
        _metaData = metadata;

        _sFileName = _metaData.filename;
        _isDirectory = _metaData.isDirectory;
        
        if (!_isDirectory)
        {
            _sDesc = [NSString stringWithFormat:@"%@ - %@",_metaData.humanReadableSize,[Utils getDateStringFromDate:_metaData.lastModifiedDate dateFormat:@"dd/MM/yyyy"]];
            
            _isDirectory = _metaData.isDirectory;
            
            NSString *sExtension = [[_sFileName pathExtension] lowercaseString];
            if ([sExtension isEqualToString:@"mp3"]) {
                _iType = kFileTypeMP3;
            }
            else if ([sExtension isEqualToString:@"m4a"]) {
                _iType = kFileTypeM4A;
            }
            else if ([sExtension isEqualToString:@"wma"]) {
                _iType = kFileTypeWMA;
            }
            else if ([sExtension isEqualToString:@"wav"]) {
                _iType = kFileTypeWAV;
            }
            else if ([sExtension isEqualToString:@"aac"]) {
                _iType = kFileTypeAAC;
            }
            else if ([sExtension isEqualToString:@"ogg"]) {
                _iType = kFileTypeOGG;
            }
            else {
                return nil;
            }
            
            _sDownloadPath = [[Utils cachePath] stringByAppendingPathComponent:_sFileName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:_sDownloadPath]) {
                [[NSFileManager defaultManager] removeItemAtPath:_sDownloadPath error:nil];
            }
            
            NSString *sName = [_sFileName stringByDeletingPathExtension];
            NSString *sFileName = nil;

            int count = 0;
            do {
                NSString *numberString = count > 0 ? [NSString stringWithFormat:@"-%d",count] : @"";
                sFileName = [NSString stringWithFormat:@"%@%@.m4a",sName,numberString];
                _sExportPath = [[Utils dropboxPath] stringByAppendingPathComponent:sFileName];
                count++;
            } while ([[NSFileManager defaultManager] fileExistsAtPath:_sExportPath]);
        }
        else {
            _iType = kFileTypeFolder;
        }
        
        _isSelected = NO;
        _isDownloadSuccess = NO;
        _fProgress = 0.0;
    }
    
    return self;
}

- (NSDictionary *)songInfo
{
    if (!_songInfo)
    {
        NSString *sTitle = nil;
        NSString *sAlbumName = nil;
        NSString *sArtistName = nil;
        NSString *sGenre = nil;
        NSString *sYear = nil;
        NSString *sLyrics = nil;
        UIImage *artwork = nil;
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.sDownloadPath] options:nil];
        
        for (AVMetadataItem *item in [asset commonMetadata])
        {
            NSString *sCommon = [item commonKey];
            
            if ([sCommon isEqualToString:AVMetadataCommonKeyTitle]) {
                sTitle = [item.value copyWithZone:nil];
            }
            else if ([sCommon isEqualToString:AVMetadataCommonKeyCreationDate]) {
                sYear = [item.value copyWithZone:nil];
            }
            else if ([sCommon isEqualToString:AVMetadataCommonKeyType]) {
                sGenre = [item stringValue];
            }
            else if ([sCommon isEqualToString:AVMetadataCommonKeyAlbumName]) {
                sAlbumName = [item.value copyWithZone:nil];
            }
            else if ([sCommon isEqualToString:AVMetadataCommonKeyArtist]) {
                sArtistName = [item.value copyWithZone:nil];
            }
            else if ([sCommon isEqualToString:AVMetadataCommonKeyArtwork]) {
                artwork = [UIImage imageWithData:[item.value copyWithZone:nil]];
            }
        }
        
        NSArray *tmpAray = nil;
        AVMetadataItem *item = nil;
        NSArray *listItem = nil;
        
        for (NSString *format in [asset availableMetadataFormats])
        {
            listItem = [asset metadataForFormat:format];
            
            if ([format isEqualToString:AVMetadataFormatID3Metadata])
            {
                tmpAray = [AVMetadataItem metadataItemsFromArray:listItem withKey:AVMetadataID3MetadataKeyContentType keySpace:AVMetadataKeySpaceID3];
                if (tmpAray.count > 0) {
                    item = [tmpAray firstObject];
                    sGenre = [item.value copyWithZone:nil];
                }
                
                tmpAray = [AVMetadataItem metadataItemsFromArray:listItem withKey:AVMetadataID3MetadataKeyYear keySpace:AVMetadataKeySpaceID3];
                if (tmpAray.count > 0) {
                    item = [tmpAray firstObject];
                    sYear = [item.value copyWithZone:nil];
                }
                
                tmpAray = [AVMetadataItem metadataItemsFromArray:listItem withKey:AVMetadataID3MetadataKeyUnsynchronizedLyric keySpace:AVMetadataKeySpaceID3];
                if (tmpAray.count > 0) {
                    item = [tmpAray firstObject];
                    sLyrics = [item.value copyWithZone:nil];
                }
            }
            else if ([format isEqualToString:AVMetadataFormatiTunesMetadata])
            {
                tmpAray = [AVMetadataItem metadataItemsFromArray:listItem withKey:AVMetadataiTunesMetadataKeyUserGenre keySpace:AVMetadataKeySpaceiTunes];
                if (tmpAray.count > 0) {
                    item = [tmpAray firstObject];
                    sGenre = [item.value copyWithZone:nil];
                }
                
                tmpAray = [AVMetadataItem metadataItemsFromArray:listItem withKey:AVMetadataiTunesMetadataKeyReleaseDate keySpace:AVMetadataKeySpaceiTunes];
                if (tmpAray.count > 0) {
                    item = [tmpAray firstObject];
                    sYear = [item.value copyWithZone:nil];
                }
                
                tmpAray = [AVMetadataItem metadataItemsFromArray:listItem withKey:AVMetadataiTunesMetadataKeyLyrics keySpace:AVMetadataKeySpaceiTunes];
                if (tmpAray.count > 0) {
                    item = [tmpAray firstObject];
                    sLyrics = [item.value copyWithZone:nil];
                }
            }
        }
        
        NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
        
        if (sTitle)
        {
            [info setObject:sTitle forKey:@"title"];
        }
        
        if (sAlbumName) {
            [info setObject:sAlbumName forKey:@"album"];
        }
        
        if (sArtistName) {
            [info setObject:sArtistName forKey:@"artist"];
        }
        
        if (sGenre) {
            [info setObject:sArtistName forKey:@"genre"];
        }
        
        if (sYear) {
            [info setObject:sYear forKey:@"year"];
        }
        
        if (artwork) {
            [info setObject:artwork forKey:@"artwork"];
        }
        
        if (sLyrics) {
            [info setObject:sLyrics forKey:@"lyrics"];
        }
        
        _songInfo = [info copy];
    }
    return _songInfo;
}

- (NSArray *)songMetaData
{
    if (!_songMetaData)
    {
        NSString *sTitle = [self.songInfo objectForKey:@"title"];
        NSString *sAlbumName = [self.songInfo objectForKey:@"album"];
        NSString *sArtistName = [self.songInfo objectForKey:@"artist"];
        NSString *sGenre = [self.songInfo objectForKey:@"genre"];
        NSString *sYear = [self.songInfo objectForKey:@"year"];
        NSString *sLyrics = [self.songInfo objectForKey:@"lyrics"];
        UIImage *artwork = [self.songInfo objectForKey:@"artwork"];
        
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
            AVMutableMetadataItem *item = [[AVMutableMetadataItem alloc] init];
            item.locale = [NSLocale currentLocale];
            item.keySpace = AVMetadataKeySpaceCommon;
            item.key = AVMetadataCommonKeyType;
            item.value = sGenre;
            [metadata addObject:item];
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
        
        _songMetaData = [metadata copy];
    }
    return _songMetaData;
}

- (void)prepareMetadata
{
    /*
     https://github.com/BeamApp/MusicPlayerViewController
     NVDSPExample
     */
    
    
}

@end

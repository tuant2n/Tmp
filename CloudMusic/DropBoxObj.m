//
//  DropBoxObj.m
//  CloudMusic
//
//  Created by TuanTN on 4/9/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "DropBoxObj.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <DropboxSDK/DropboxSDK.h>

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
            
            _sDownloadPath = [[Utils dropboxPath] stringByAppendingPathComponent:_sFileName];
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

- (void)prepareMetadata
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
    
    if (sLyrics) {
        AVMutableMetadataItem *item = [[AVMutableMetadataItem alloc] init];
        item.locale = [NSLocale currentLocale];
        item.keySpace = AVMetadataKeySpaceiTunes;
        item.key = AVMetadataiTunesMetadataKeyLyrics;
        item.value = sLyrics;
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
}

@end

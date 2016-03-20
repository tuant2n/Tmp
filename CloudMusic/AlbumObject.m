//
//  AlbumObject.m
//  CloudMusic
//
//  Created by TuanTN on 3/17/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "AlbumObject.h"

#import "Utils.h"

@implementation AlbumObject

- (id)initWithInfo:(NSDictionary *)albumInfo
{
    self = [super init];
    
    if (self) {
        _iAlbumId = [albumInfo objectForKey:@"iAlbumId"];
        _sAlbumTitle = [albumInfo objectForKey:@"sAlbumTitle"];
        
        _iAlbumArtistId = [albumInfo objectForKey:@"iAlbumArtistId"];
        _sAlbumArtist = [albumInfo objectForKey:@"sAlbumArtist"];
        
        NSString *sArtworkName = [albumInfo objectForKey:@"sArtworkName"];
        if (sArtworkName) {
            NSString *sArtworkPath = [[Utils artworkPath] stringByAppendingPathComponent:sArtworkName];
            _imgArtwork = [UIImage imageWithContentsOfFile:sArtworkPath];
        }
        
        _iTrackCount = [[albumInfo objectForKey:@"iTrackCount"] intValue];
        _iYear = [[albumInfo objectForKey:@"iYear"] intValue];
    }
    
    return self;
}

@end

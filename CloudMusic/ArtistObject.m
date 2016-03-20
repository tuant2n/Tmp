//
//  ArtistObject.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/19/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "ArtistObject.h"

#import "Utils.h"

@implementation ArtistObject

- (id)initWithInfo:(NSDictionary *)artistInfo
{
    self = [super init];
    
    if (self) {
        _iArtistId = [artistInfo objectForKey:@"iArtistId"];
        _sArtist = [artistInfo objectForKey:@"sArtist"];
        
        NSString *sArtworkName = [artistInfo objectForKey:@"sArtworkName"];
        if (sArtworkName) {
            NSString *sArtworkPath = [[Utils artworkPath] stringByAppendingPathComponent:sArtworkName];
            _imgArtwork = [UIImage imageWithContentsOfFile:sArtworkPath];
        }
        
        _iTrackCount = [[artistInfo objectForKey:@"iTrackCount"] intValue];
        _iYear = [[artistInfo objectForKey:@"iYear"] intValue];
    }
    
    return self;
}

@end

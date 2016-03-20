//
//  GenreObject.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/19/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "GenreObject.h"

#import "Utils.h"

@implementation GenreObject

- (id)initWithInfo:(NSDictionary *)genreInfo
{
    self = [super init];
    
    if (self) {
        _iGenreId = [genreInfo objectForKey:@"iGenreId"];
        _sGenre = [genreInfo objectForKey:@"sGenre"];
        
        NSString *sArtworkName = [genreInfo objectForKey:@"sArtworkName"];
        if (sArtworkName) {
            NSString *sArtworkPath = [[Utils artworkPath] stringByAppendingPathComponent:sArtworkName];
            _imgArtwork = [UIImage imageWithContentsOfFile:sArtworkPath];
        }
        
        _iTrackCount = [[genreInfo objectForKey:@"iTrackCount"] intValue];
        _iYear = [[genreInfo objectForKey:@"iYear"] intValue];
    }
    
    return self;
}

@end

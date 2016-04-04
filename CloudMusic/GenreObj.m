//
//  GenresObj.m
//  CloudMusic
//
//  Created by TuanTN on 3/28/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "GenreObj.h"

#import "Utils.h"

@implementation GenreObj

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    
    if (self) {
        self.iGenreId = [info objectForKey:@"iGenreId"];
        self.sGenreName = [info objectForKey:@"sGenreName"];
        
        if ([info objectForKey:@"sArtworkName"]) {
            self.sLocalArtworkUrl = [NSURL fileURLWithPath:[[Utils artworkPath] stringByAppendingPathComponent:[info objectForKey:@"sArtworkName"]]];
        }
        
        self.isCloud = ([[info objectForKey:@"iCloud"] intValue] == 1);
        
        int numberOfSong = [[info objectForKey:@"numberOfSong"] intValue];
        int fDuration = [[info objectForKey:@"fDuration"] intValue];
        self.sGenreDesc = [NSString stringWithFormat:@"%d Songs, %@",numberOfSong,[Utils timeFormattedForList:fDuration]];
    }
    
    return self;
}

@end

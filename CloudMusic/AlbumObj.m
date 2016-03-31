//
//  AlbumObj.m
//  CloudMusic
//
//  Created by TuanTN on 3/26/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "AlbumObj.h"

#import "Utils.h"

@implementation AlbumObj

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    
    if (self)
    {
        self.iAlbumId = [info objectForKey:@"iAlbumId"];
        
        self.sAlbumName = [info objectForKey:@"sAlbumName"];
        self.sAlbumArtistName = [info objectForKey:@"sAlbumArtistName"];
        
        if ([info objectForKey:@"sArtworkName"]) {
            self.sLocalArtworkUrl = [NSURL fileURLWithPath:[[Utils artworkPath] stringByAppendingPathComponent:[info objectForKey:@"sArtworkName"]]];
        }
        
        self.isCloud = [[info objectForKey:@"isCloud"] boolValue];
        
        self.iYear = [info objectForKey:@"iYear"];
        self.sAlbumInfo = self.sAlbumArtistName;
        if (self.iYear.intValue > 0) {
            self.sAlbumInfo = [NSString stringWithFormat:@"%@, %d",self.sAlbumInfo,self.iYear.intValue];
        }

        int numberOfSong = [[info objectForKey:@"numberOfSong"] intValue];
        int fDuration = [[info objectForKey:@"fDuration"] intValue];
        self.sAlbumDesc = [NSString stringWithFormat:@"%d Songs, %@",numberOfSong,[Utils timeFormattedForList:fDuration]];
    }
    
    return self;
}

@end

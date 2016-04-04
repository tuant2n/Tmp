//
//  AlbumArtistObj.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/28/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "AlbumArtistObj.h"

#import "Utils.h"

@implementation AlbumArtistObj

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    
    if (self) {
        self.iAlbumArtistId = [info objectForKey:@"iAlbumArtistId"];
        self.sAlbumArtistName = [info objectForKey:@"sAlbumArtistName"];

        if ([info objectForKey:@"sArtworkName"]) {
            self.sLocalArtworkUrl = [NSURL fileURLWithPath:[[Utils artworkPath] stringByAppendingPathComponent:[info objectForKey:@"sArtworkName"]]];
        }
        
        self.isCloud = ([[info objectForKey:@"iCloud"] intValue] == 1);;
        
        self.numberOfAlbum = [[info objectForKey:@"numberOfAlbum"] intValue];
        int numberOfSong = [[info objectForKey:@"numberOfSong"] intValue];
        self.sAlbumArtistDesc = [NSString stringWithFormat:@"%d Albums, %d Songs",self.numberOfAlbum,numberOfSong];
    }
    
    return self;
}

@end

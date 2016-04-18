//
//  Playlist.m
//  CloudMusic
//
//  Created by TuanTN on 4/18/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "Playlist.h"

@implementation Playlist

// Insert code here to add functionality to your managed object subclass

- (void)setPlaylist:(NSArray *)listSong
{
    self.listSong = [NSKeyedArchiver archivedDataWithRootObject:listSong];
}

- (NSArray *)getPlaylist
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.listSong];
}

@end

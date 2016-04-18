//
//  PlaylistCell.m
//  CloudMusic
//
//  Created by TuanTN on 4/18/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "PlaylistsCell.h"

#import "Playlist.h"
#import "Utils.h"

@interface PlaylistsCell()

@property (nonatomic, weak) IBOutlet UILabel *lblPlaylistName, *lblPlaylistDesc;

@end

@implementation PlaylistsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lblPlaylistDesc.textColor = [Utils colorWithRGBHex:0x6a6a6a];
}

- (void)config:(Playlist *)playlist
{
    self.lblPlaylistName.text = playlist.sPlaylistName;
    self.lblPlaylistDesc.text = playlist.sPlaylistDesc;
    
    [self setArtwork:playlist.sLocalArtworkUrl];
}

@end

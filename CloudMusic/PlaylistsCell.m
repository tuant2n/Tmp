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
@property (nonatomic, weak) IBOutlet UIButton *btnEditName;

@end

@implementation PlaylistsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.lblPlaylistDesc.textColor = [Utils colorWithRGBHex:0x6a6a6a];
    [self.btnEditName addTarget:self action:@selector(touchEditName:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)config:(Playlist *)playlist
{
    self.currentPlaylist = playlist;
    
    self.lblPlaylistName.text = self.currentPlaylist.sPlaylistName;
    self.lblPlaylistDesc.text = self.currentPlaylist.sPlaylistDesc;
    
    [self setArtwork:self.currentPlaylist.sLocalArtworkUrl];
    
    if (self.currentPlaylist.isSmartPlaylist.boolValue) {
        self.imgvListIcon.hidden = NO;
        self.btnEditName.hidden = YES;
    }
    else {
        [self configRightMenu:YES hasIndexTitle:NO];
        self.imgvListIcon.hidden = YES;
        self.btnEditName.hidden = NO;
    }
}

- (void)touchEditName:(id)sender
{
    if (!self.currentPlaylist) {
        return;
    }
    
    if ([self.subDelegate respondsToSelector:@selector(changePlaylistName:)]) {
        [self.subDelegate changePlaylistName:self.currentPlaylist];
    }
}

@end

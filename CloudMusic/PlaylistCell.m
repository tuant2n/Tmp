//
//  PlaylistCell.m
//  CloudMusic
//
//  Created by TuanTN on 4/20/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "PlaylistCell.h"

#import "Playlist.h"

@interface PlaylistCell()

@property (nonatomic, weak) IBOutlet UILabel *lblPlaylistName;

@end

@implementation PlaylistCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)configWithPlaylist:(Playlist *)playlist
{
    self.lblPlaylistName.text = playlist.sPlaylistName;
}

+ (CGFloat)heigth
{
    return 40.0;
}

@end

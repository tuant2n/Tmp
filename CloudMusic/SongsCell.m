//
//  SongsCell.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/25/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "SongsCell.h"

#import "Item.h"

#import "Utils.h"

@interface SongsCell()

@property (nonatomic, weak) IBOutlet UILabel *lblSongName, *lblSongDesc, *lblDuration;

@end

@implementation SongsCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.lblDuration.textColor = [Utils colorWithRGBHex:0x545454];
}

- (void)config:(Item *)song
{    
    [self setArtwork:song.sLocalArtworkUrl];
    
    self.lblSongName.text = song.sSongName;
    self.lblSongDesc.attributedText = song.sSongDesc;
    self.lblDuration.text = song.sDuration;
    
    [self configMenuButton:song.isCloud isEdit:YES hasIndexTitle:YES];
    [self setItemType:song.isCloud];
    [self isPlaying:song.isPlaying];
}

- (void)configWithoutMenu:(Item *)song
{
    [self setArtwork:song.sLocalArtworkUrl];
    
    self.lblSongName.text = song.sSongName;
    self.lblSongDesc.attributedText = song.sSongDesc;
    self.lblDuration.text = song.sDuration;
    
    [self setItemType:song.isCloud];
    [self isPlaying:song.isPlaying];
}

@end

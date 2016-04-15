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

- (void)config:(Item *)item
{
    [self setArtwork:item.sLocalArtworkUrl];
    
    self.lblSongName.text = item.sSongName;
    self.lblSongDesc.attributedText = item.sSongDesc;
    self.lblDuration.text = item.sDuration;
    
    [self configMenuButton:item.isCloud isEdit:YES];
    [self setItemType:item.isCloud];
    [self isPlaying:item.isPlaying];
}

@end

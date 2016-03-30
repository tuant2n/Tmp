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
{
    MGSwipeButton *editBtn, *deleteBtn, *addToPlaylistBtn;
}

@property (nonatomic, weak) IBOutlet UILabel *lblSongName, *lblSongDesc, *lblDuration;

@end

@implementation SongsCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.lblDuration.textColor = [Utils colorWithRGBHex:0x545454];
    
    deleteBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnDelete"] backgroundColor:[Utils colorWithRGBHex:0xFF0000]];
    addToPlaylistBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnAddPlaylist"] backgroundColor:[Utils colorWithRGBHex:0x03C9A9]];
    editBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnEditSong"] backgroundColor:[Utils colorWithRGBHex:0x3498db]];
}

- (void)config:(Item *)item
{
    [self setArtwork:item.sLocalArtworkUrl];
    
    self.lblSongName.text = item.sSongName;
    self.lblSongDesc.attributedText = item.sSongDesc;
    
    self.lblDuration.text = item.sDuration;
    
    if (item.isCloud.boolValue) {
        self.leftButtons = @[deleteBtn,addToPlaylistBtn,editBtn];
    }
    else {
        self.leftButtons = @[addToPlaylistBtn];
    }
    
    [self setItemType:item.isCloud.boolValue];
    [self isPlaying:item.isPlaying];
}

+ (CGFloat)height
{
    return 62.0;
}

@end

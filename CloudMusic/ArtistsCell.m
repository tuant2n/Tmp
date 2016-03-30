//
//  ArtistsCell.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/28/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "ArtistsCell.h"

#import "AlbumArtistObj.h"
#import "Utils.h"

@interface ArtistsCell()
{
    MGSwipeButton *deleteBtn, *addToPlaylistBtn;
}

@property (nonatomic, weak) IBOutlet UILabel *lblAlbumArtistName, *lblAlbumArtisDesc;

@end

@implementation ArtistsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.lblAlbumArtisDesc.textColor = [Utils colorWithRGBHex:0x6a6a6a];

    deleteBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnDelete"] backgroundColor:[Utils colorWithRGBHex:0xFF0000]];
    addToPlaylistBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnAddPlaylist"] backgroundColor:[Utils colorWithRGBHex:0x03C9A9]];
}

- (void)config:(AlbumArtistObj *)item
{
    [self setArtwork:item.sLocalArtworkUrl];

    self.lblAlbumArtistName.text = item.sAlbumArtistName;
    self.lblAlbumArtisDesc.text = item.sAlbumArtistDesc;

    if (item.isCloud) {
        self.leftButtons = @[deleteBtn,addToPlaylistBtn];
    }
    else {
        self.leftButtons = @[addToPlaylistBtn];
    }
    
    [self setItemType:item.isCloud];
    [self isPlaying:item.isPlaying];
}

+ (CGFloat)height
{
    return 62.0;
}

@end

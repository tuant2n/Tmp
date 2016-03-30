//
//  AlbumsCell.m
//  CloudMusic
//
//  Created by TuanTN on 3/26/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "AlbumsCell.h"

#import "AlbumObj.h"
#import "Utils.h"

@interface AlbumsCell()
{
    MGSwipeButton *editBtn, *deleteBtn, *addToPlaylistBtn;
}

@property (nonatomic, weak) IBOutlet UILabel *lblAlbumName, *lblAlbumInfo, *lblAlbumDesc;

@end

@implementation AlbumsCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    deleteBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnDelete"] backgroundColor:[Utils colorWithRGBHex:0xFF0000]];
    addToPlaylistBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnAddPlaylist"] backgroundColor:[Utils colorWithRGBHex:0x03C9A9]];
    editBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnEditSong"] backgroundColor:[Utils colorWithRGBHex:0x3498db]];
}

- (void)config:(AlbumObj *)item
{
    [self setArtwork:item.sLocalArtworkUrl];

    self.lblAlbumName.text = item.sAlbumName;
    self.lblAlbumInfo.text = item.sAlbumInfo;
    self.lblAlbumDesc.text = item.sAlbumDesc;
    
    if (item.isCloud) {
        self.leftButtons = @[deleteBtn,addToPlaylistBtn,editBtn];
    }
    else {
        self.leftButtons = @[addToPlaylistBtn];
    }

    [self setItemType:item.isCloud];
    [self isPlaying:item.isPlaying];
}

+ (CGFloat)height
{
    return 82.0;
}

@end

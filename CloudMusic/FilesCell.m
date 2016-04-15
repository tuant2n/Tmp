//
//  FilesCell.m
//  CloudMusic
//
//  Created by TuanTN on 4/9/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "FilesCell.h"

#import "Item.h"
#import "FileInfo.h"
#import "FileObj.h"

#import "Utils.h"

@interface FilesCell()
{
    MGSwipeButton *renameBtn, *addToPlaylistBtn, *editTagBtn, *deleteBtn;
    NSArray *menuItems;
}

@property (nonatomic, weak) IBOutlet UILabel *lblSongName, *lblSongDesc, *lblDuration;

@end

@implementation FilesCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.lblDuration.textColor = [Utils colorWithRGBHex:0x545454];
    self.lblSongDesc.textColor = [Utils colorWithRGBHex:0x6a6a6a];
    
    renameBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnRename"] backgroundColor:[Utils colorWithRGBHex:0x8e44ad]];
    addToPlaylistBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnAddPlaylist"] backgroundColor:[Utils colorWithRGBHex:0x03C9A9]];
    editTagBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnEditSong"] backgroundColor:[Utils colorWithRGBHex:0x3498db]];
    deleteBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnDelete"] backgroundColor:[Utils colorWithRGBHex:0xFF0000]];
    menuItems = [NSArray arrayWithObjects:deleteBtn,addToPlaylistBtn,editTagBtn,renameBtn,nil];
}

- (void)config:(FileObj *)file
{
    [self setArtwork:file.item.sLocalArtworkUrl];
    
    self.lblSongName.text = file.item.sSongName;
    self.lblSongDesc.text = file.item.fileInfo.sTimeStamp;
    self.lblDuration.text = file.item.sDuration;
    
    [self isPlaying:file.item.isPlaying];
    self.leftButtons = menuItems;
}

@end

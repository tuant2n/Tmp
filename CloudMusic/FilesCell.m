//
//  FilesCell.m
//  CloudMusic
//
//  Created by TuanTN on 4/9/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "FilesCell.h"

#import "Item.h"
#import "File.h"

#import "Utils.h"

@interface FilesCell()

@property (nonatomic, weak) IBOutlet UILabel *lblSongName, *lblSongDesc, *lblDuration;

@end

@implementation FilesCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.lblDuration.textColor = [Utils colorWithRGBHex:0x545454];
    self.lblSongDesc.textColor = [Utils colorWithRGBHex:0x6a6a6a];
}

- (void)config:(File *)file
{
    [self setArtwork:file.item.sLocalArtworkUrl];
    self.lblDuration.text = file.item.sDuration;
    
    self.lblSongName.text = file.sFileName;
    self.lblSongDesc.text = file.sTimeStamp;
    
    [self configMenuButton:YES isEdit:YES hasIndexTitle:NO];
    [self isPlaying:file.item.isPlaying];
}

@end

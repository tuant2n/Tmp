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

@property (nonatomic, weak) IBOutlet UILabel *lblAlbumArtistName, *lblAlbumArtisDesc;

@end

@implementation ArtistsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)config:(AlbumArtistObj *)item
{
    [self setArtwork:item.sLocalArtworkUrl];

    self.lblAlbumArtistName.text = item.sAlbumArtistName;
    self.lblAlbumArtisDesc.text = item.sAlbumArtistDesc;

    [self configMenuButton:item.isCloud isEdit:NO hasIndexTitle:NO];
    [self setItemType:item.isCloud];
    [self isPlaying:item.isPlaying];
}

@end

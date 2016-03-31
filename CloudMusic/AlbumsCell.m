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

@property (nonatomic, weak) IBOutlet UILabel *lblAlbumName, *lblAlbumInfo, *lblAlbumDesc;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *vInfoPosition;

@end

@implementation AlbumsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)config:(AlbumObj *)item
{
    [self setArtwork:item.sLocalArtworkUrl];

    self.lblAlbumName.text = item.sAlbumName;
    self.lblAlbumInfo.text = item.sAlbumInfo;
    self.lblAlbumDesc.text = item.sAlbumDesc;
    
    [self configMenuButton:item.isCloud isEdit:YES];
    [self setItemType:item.isCloud];
    [self isPlaying:item.isPlaying];
}

- (void)hideExtenal
{
    self.imgvIcon.hidden = YES;
    self.imgvListIcon.hidden = YES;
    [self.vInfoPosition setConstant:15.0];
}

@end

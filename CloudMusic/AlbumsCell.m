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
    BOOL isNotActive;
}

@property (nonatomic, weak) IBOutlet UILabel *lblAlbumName, *lblAlbumInfo, *lblAlbumDesc;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *vInfoPosition;

@property (nonatomic, weak) IBOutlet UIView *vExternal;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *vExternalWidth;;

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
    self.vExternal.hidden = YES;
    self.imgvListIcon.hidden = YES;
    
    [self.vExternalWidth setConstant:0.0];
    [self.vInfoPosition setConstant:15.0];
    
    self.leftButtons = nil;
    isNotActive = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (!isNotActive) {
        [super setHighlighted:highlighted animated:animated];
    }
}

@end

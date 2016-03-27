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

#import "UIImageView+WebCache.h"
#import "VYPlayIndicator.h"

@interface AlbumsCell()
{
    UIImage *placeHolder;
    UIImage *iTunesIcon, *cloudIcon;
    
    MGSwipeButton *editBtn, *deleteBtn, *addToPlaylistBtn;
}

@property (nonatomic, weak) IBOutlet UIImageView *imgvArtwork;
@property (nonatomic, weak) IBOutlet UILabel *lblAlbumName, *lblAlbumInfo, *lblAlbumDesc;

@property (nonatomic, weak) IBOutlet UIView *vMusicEq;
@property (nonatomic, strong) VYPlayIndicator *musicEq;

@property (nonatomic, weak) IBOutlet UIImageView *imgvIcon;
@property (nonatomic, weak) IBOutlet UIView *line;

@end

@implementation AlbumsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.imgvArtwork.clipsToBounds = YES;
    self.imgvArtwork.contentMode = UIViewContentModeScaleAspectFill;
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];

    self.musicEq = [[VYPlayIndicator alloc] init];
    [self.musicEq setColor:[UIColor redColor]];
    self.musicEq.frame = self.vMusicEq.bounds;
    [self.vMusicEq.layer addSublayer:self.musicEq];
    
    placeHolder = [UIImage imageNamed:@"filetype_audio"];
    iTunesIcon = [UIImage imageNamed:@"ipod-item-icon"];
    cloudIcon = [UIImage imageNamed:@"cloud-item-icon"];
    
    self.leftSwipeSettings.transition = MGSwipeTransitionStatic;
    self.leftExpansion.buttonIndex = -1;
    self.leftExpansion.fillOnTrigger = YES;
    
    deleteBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnDelete"] backgroundColor:[Utils colorWithRGBHex:0xFF0000]];
    addToPlaylistBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnAddPlaylist"] backgroundColor:[Utils colorWithRGBHex:0x03C9A9]];
    editBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnEditSong"] backgroundColor:[Utils colorWithRGBHex:0x3498db]];
}

- (void)config:(AlbumObj *)item
{
    [self.imgvArtwork sd_setImageWithURL:item.sLocalArtworkUrl placeholderImage:placeHolder options:SDWebImageRetryFailed];
    
    self.lblAlbumName.text = item.sAlbumName;
    self.lblAlbumInfo.text = item.sAlbumInfo;
    self.lblAlbumDesc.text = item.sAlbumDesc;
    
    if (item.isCloud) {
        self.imgvIcon.image = cloudIcon;
        self.leftButtons = @[deleteBtn,addToPlaylistBtn,editBtn];
    }
    else {
        self.imgvIcon.image = iTunesIcon;
        self.leftButtons = @[addToPlaylistBtn];
    }

    [self isPlaying:item.isPlaying];
}

- (void)setLineHidden:(BOOL)isHidden
{
    self.line.hidden = isHidden;
}

- (void)isPlaying:(BOOL)isPlaying
{
    if (isPlaying) {
        [self.musicEq animatePlayback];
    }
    else {
        [self.musicEq stopPlayback];
    }
}

+ (CGFloat)height
{
    return 82.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

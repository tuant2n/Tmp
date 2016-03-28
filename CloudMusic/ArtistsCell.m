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

#import "UIImageView+WebCache.h"
#import "VYPlayIndicator.h"

@interface ArtistsCell()
{
    UIImage *placeHolder, *iTunesIcon, *cloudIcon;
    UIColor *bgColor, *highlightColor;
    
    MGSwipeButton *deleteBtn, *addToPlaylistBtn;
}

@property (nonatomic, weak) IBOutlet UIImageView *imgvArtwork;
@property (nonatomic, weak) IBOutlet UILabel *lblAlbumArtistName, *lblAlbumArtisDesc;

@property (nonatomic, weak) IBOutlet UIView *vContent;

@property (nonatomic, weak) IBOutlet UIView *vMusicEq;
@property (nonatomic, strong) VYPlayIndicator *musicEq;

@property (nonatomic, weak) IBOutlet UIImageView *imgvIcon;
@property (nonatomic, weak) IBOutlet UIView *line;

@end

@implementation ArtistsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.imgvArtwork.clipsToBounds = YES;
    self.imgvArtwork.contentMode = UIViewContentModeScaleAspectFill;
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    self.lblAlbumArtisDesc.textColor = [Utils colorWithRGBHex:0x6a6a6a];
    
    self.musicEq = [[VYPlayIndicator alloc] init];
    [self.musicEq setColor:[UIColor redColor]];
    self.musicEq.frame = self.vMusicEq.bounds;
    [self.vMusicEq.layer addSublayer:self.musicEq];
    
    placeHolder = [UIImage imageNamed:@"filetype_audio"];
    iTunesIcon = [UIImage imageNamed:@"ipod-item-icon"];
    cloudIcon = [UIImage imageNamed:@"cloud-item-icon"];
    
    bgColor = [UIColor whiteColor];
    highlightColor = [Utils colorWithRGBHex:0xe4f2ff];
    
    self.leftSwipeSettings.transition = MGSwipeTransitionStatic;
    self.leftExpansion.buttonIndex = -1;
    self.leftExpansion.fillOnTrigger = YES;
    
    deleteBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnDelete"] backgroundColor:[Utils colorWithRGBHex:0xFF0000]];
    addToPlaylistBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnAddPlaylist"] backgroundColor:[Utils colorWithRGBHex:0x03C9A9]];
}

- (void)config:(AlbumArtistObj *)item
{
    [self.imgvArtwork sd_setImageWithURL:item.sLocalArtworkUrl placeholderImage:placeHolder options:SDWebImageRetryFailed];
    
    self.lblAlbumArtistName.text = item.sAlbumArtistName;
    self.lblAlbumArtisDesc.text = item.sAlbumArtistDesc;

    if (item.isCloud) {
        self.imgvIcon.image = cloudIcon;
        self.leftButtons = @[deleteBtn,addToPlaylistBtn];
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
    return 62.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted)
    {
        self.vContent.backgroundColor = highlightColor;
    }
    else {
        self.vContent.backgroundColor = bgColor;
    }
}

@end

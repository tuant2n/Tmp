//
//  MainCell.m
//  CloudMusic
//
//  Created by TuanTN on 3/30/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "MainCell.h"

#import "Utils.h"

#import "VYPlayIndicator.h"
#import "UIImageView+WebCache.h"

@interface MainCell()
{
    UIImage *placeHolder, *iTunesIcon, *cloudIcon;
    UIColor *bgColor, *highlightColor;
    
    MGSwipeButton *editBtn, *deleteBtn, *addToPlaylistBtn;
}

@end

@implementation MainCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.imgvArtwork.clipsToBounds = YES;
    self.imgvArtwork.contentMode = UIViewContentModeScaleAspectFill;
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    
    bgColor = [UIColor whiteColor];
    highlightColor = [Utils colorWithRGBHex:0xe4f2ff];
    
    if ([self isKindOfClass:[PlaylistsCell class]]) {
        placeHolder = [UIImage imageNamed:@"playlist_icon"];
    }
    else {
        placeHolder = [UIImage imageNamed:@"filetype_audio"];
    }
    
    iTunesIcon = [UIImage imageNamed:@"ipod-item-icon"];
    cloudIcon = [UIImage imageNamed:@"cloud-item-icon"];
    
    self.musicEq = [[VYPlayIndicator alloc] init];
    [self.musicEq setColor:[UIColor redColor]];
    self.musicEq.frame = self.vMusicEq.bounds;
    [self.vMusicEq.layer addSublayer:self.musicEq];
    
    self.leftSwipeSettings.transition = MGSwipeTransitionStatic;
    self.leftExpansion.buttonIndex = -1;
    self.leftExpansion.fillOnTrigger = YES;
    
    deleteBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnDelete"] backgroundColor:[Utils colorWithRGBHex:0xEF4836]];
    addToPlaylistBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnAddPlaylist"] backgroundColor:[Utils colorWithRGBHex:0x00B16A]];
    editBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnEditSong"] backgroundColor:[Utils colorWithRGBHex:0x9A12B3]];
}

- (void)config:(id)item
{
    
}

+ (CGFloat)normalCellHeight
{
    return 61.0;
}

+ (CGFloat)largeCellHeight
{
    return 81.0;
}

- (void)setItemType:(BOOL)isCloud
{
    self.imgvIcon.image = isCloud ? cloudIcon:iTunesIcon;
}

- (void)setArtwork:(NSURL *)sArtworkUrl
{
    [self.imgvArtwork sd_setImageWithURL:sArtworkUrl placeholderImage:placeHolder options:SDWebImageRetryFailed];
}

- (void)configMenuButton:(BOOL)isCloud isEdit:(BOOL)isEdit
{
    NSMutableArray *arrayBtn = [NSMutableArray new];
    
    if (isCloud)
    {
        [arrayBtn addObject:deleteBtn];
        [arrayBtn addObject:addToPlaylistBtn];
        
        if (isEdit) {
            [arrayBtn addObject:editBtn];
        }
    }
    else {
        [arrayBtn addObject:addToPlaylistBtn];
    }
    
    self.leftButtons = arrayBtn;
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

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
    
    placeHolder = [UIImage imageNamed:@"filetype_audio"];
    iTunesIcon = [UIImage imageNamed:@"ipod-item-icon"];
    cloudIcon = [UIImage imageNamed:@"cloud-item-icon"];
    
    self.musicEq = [[VYPlayIndicator alloc] init];
    [self.musicEq setColor:[UIColor redColor]];
    self.musicEq.frame = self.vMusicEq.bounds;
    [self.vMusicEq.layer addSublayer:self.musicEq];
    
    self.leftSwipeSettings.transition = MGSwipeTransitionStatic;
    self.leftExpansion.buttonIndex = -1;
    self.leftExpansion.fillOnTrigger = YES;
}

- (void)config:(id)item
{
    
}

- (void)setItemType:(BOOL)isCloud
{
    self.imgvIcon.image = isCloud ? cloudIcon:iTunesIcon;
}

- (void)setArtwork:(NSURL *)sArtworkUrl
{
    [self.imgvArtwork sd_setImageWithURL:sArtworkUrl placeholderImage:placeHolder options:SDWebImageRetryFailed];
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

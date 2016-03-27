//
//  SongsCell.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/25/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "SongsCell.h"

#import "Item.h"

#import "Utils.h"

#import "VYPlayIndicator.h"
#import "UIImageView+WebCache.h"

@interface SongsCell()
{
    UIImage *placeHolder;
    UIImage *iTunesIcon, *cloudIcon;
    
    MGSwipeButton *editBtn, *deleteBtn, *addToPlaylistBtn;
}

@property (nonatomic, weak) IBOutlet UIImageView *imgvArtwork;
@property (nonatomic, weak) IBOutlet UILabel *lblSongName, *lblSongDesc, *lblDuration;
@property (nonatomic, weak) IBOutlet UIView *vMusicEq;
@property (nonatomic, weak) IBOutlet UIImageView *imgvIcon;
@property (nonatomic, weak) IBOutlet UIView *line;

@property (nonatomic, strong) VYPlayIndicator *musicEq;

@end

@implementation SongsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.imgvArtwork.clipsToBounds = YES;
    self.imgvArtwork.contentMode = UIViewContentModeScaleAspectFill;
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    self.lblDuration.textColor = [Utils colorWithRGBHex:0x545454];
    
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
    
    deleteBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnDelete"] backgroundColor:[Utils colorWithRGBHex:0xFF0000]];
    addToPlaylistBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnAddPlaylist"] backgroundColor:[Utils colorWithRGBHex:0x03C9A9]];
    editBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnEditSong"] backgroundColor:[Utils colorWithRGBHex:0x3498db]];
}

- (void)configWithItem:(Item *)item
{
    [self.imgvArtwork sd_setImageWithURL:item.sLocalArtworkUrl placeholderImage:placeHolder options:SDWebImageRetryFailed];
    
    self.lblSongName.text = item.sSongName;
    self.lblSongDesc.attributedText = item.sSongDesc;
    
    self.lblDuration.text = item.sDuration;
    
    if (item.isCloud.boolValue) {
        self.imgvIcon.image = cloudIcon;
        self.leftButtons = @[deleteBtn,addToPlaylistBtn,editBtn];
    }
    else {
        self.imgvIcon.image = iTunesIcon;
        self.leftButtons = @[addToPlaylistBtn];
    }
    
    [self isPlaying:item.isPlaying];
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

- (void)setLineHidden:(BOOL)isHidden
{
    self.line.hidden = isHidden;
}

+ (CGFloat)height
{
    return 62.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

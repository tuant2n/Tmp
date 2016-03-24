//
//  SongCell.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/24/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "SongCell.h"

#import "Item.h"

#import "Utils.h"

#import "VYPlayIndicator.h"
#import "UIImageView+WebCache.h"

@interface SongCell()
{
    UIImage *placeHolder;
}

@property (nonatomic, weak) IBOutlet UIImageView *imgvArtwork;
@property (nonatomic, weak) IBOutlet UILabel *lblSongName, *lblSongDesc, *lblDuration;
@property (nonatomic, weak) IBOutlet UIView *vMusicEq;
@property (nonatomic, weak) IBOutlet UIImageView *iTunesIcon;
@property (nonatomic, weak) IBOutlet UIView *line;

@property (nonatomic, strong) VYPlayIndicator *musicEq;

@end

@implementation SongCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.imgvArtwork.clipsToBounds = YES;
    self.imgvArtwork.contentMode = UIViewContentModeScaleAspectFill;
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    
    placeHolder = [UIImage imageNamed:@"filetype_audio"];
    
    self.musicEq = [[VYPlayIndicator alloc] init];
    [self.musicEq setColor:[UIColor redColor]];
    self.musicEq.frame = self.vMusicEq.bounds;
    [self.vMusicEq.layer addSublayer:self.musicEq];
}

- (void)configWithItem:(Item *)item
{
    [self.imgvArtwork sd_setImageWithURL:item.sLocalArtworkUrl placeholderImage:placeHolder options:SDWebImageRetryFailed];
    
    self.lblSongName.text = item.sSongName;
    self.lblSongDesc.attributedText = item.sSongDesc;
    
    self.lblDuration.text = item.sDuration;
    self.iTunesIcon.hidden = item.isCloud;
    
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

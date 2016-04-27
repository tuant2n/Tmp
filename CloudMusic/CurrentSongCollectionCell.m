//
//  CurrentSongCollectionCell.m
//  CloudMusic
//
//  Created by TuanTN on 4/27/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "CurrentSongCollectionCell.h"

#import "Item.h"
#import "Utils.h"

#import "UIImageView+WebCache.h"

@interface CurrentSongCollectionCell()
{
    UIImage *defaultArtwork;
}

@property (nonatomic, weak) IBOutlet UIImageView *imgvArtwork;

@end

@implementation CurrentSongCollectionCell

- (void)awakeFromNib
{
    defaultArtwork = [UIImage imageNamed:@"white-default-cover"];
    
    self.imgvArtwork.contentMode = UIViewContentModeScaleAspectFit;
    self.imgvArtwork.backgroundColor = [Utils colorWithRGBHex:0xf4f4f4];
    self.imgvArtwork.clipsToBounds = YES;
}

- (void)configWithSong:(Item *)song
{
    [self.imgvArtwork sd_setImageWithURL:song.sLocalArtworkUrl placeholderImage:defaultArtwork options:SDWebImageRetryFailed];
}

@end

//
//  ArtworkView.m
//  CloudMusic
//
//  Created by TuanTN8 on 4/2/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "ArtworkView.h"

#import "Utils.h"
#import "UIImageView+WebCache.h"

@interface ArtworkView()

@property (nonatomic, weak) IBOutlet UIImageView *imgvArtwork;

@end

@implementation ArtworkView

- (void)setArtwotk:(NSURL *)sArtworkUrl
{
    [self.imgvArtwork sd_setImageWithURL:sArtworkUrl placeholderImage:[UIImage imageNamed:@"filetype_audio"] options:SDWebImageRetryFailed];
}

- (void)awakeFromNib
{
    self.backgroundColor = [Utils colorWithRGBHex:0xf0f0f0];
}

@end

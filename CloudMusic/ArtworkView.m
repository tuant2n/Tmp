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
{
    NSURL *sArtworkUrl;
    UIImage *artwork;
    
    BOOL isChange;
}

@property (nonatomic, weak) IBOutlet UIImageView *imgvArtwork;
@property (nonatomic, weak) IBOutlet UIView *vEdit;

@end

@implementation ArtworkView

- (void)setArtwotk:(NSURL *)sUrl
{
    sArtworkUrl = sUrl;
    
    if (!sArtworkUrl) {
        self.imgvArtwork.hidden = YES;
        self.vEdit.hidden = NO;
        artwork = nil;
    }
    else {
        self.imgvArtwork.hidden = NO;
        self.vEdit.hidden = YES;
        
        [self.imgvArtwork sd_setImageWithURL:sArtworkUrl placeholderImage:[UIImage imageNamed:@"filetype_audio"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) \
        {
            if (!error) {
                artwork = image;
            }
        }];
    }
}

- (void)setArtworkImage:(UIImage *)image
{
    isChange = YES;
    
    artwork = image;
    self.imgvArtwork.image = artwork;
    
    self.imgvArtwork.hidden = NO;
    self.vEdit.hidden = YES;
}

- (UIImage *)artwork
{
    return artwork;
}

- (BOOL)isChangeArtwork
{
    return isChange;
}

- (IBAction)touchChangeArtwork:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(changeArtwork)]) {
        [self.delegate changeArtwork];
    }
}

- (void)awakeFromNib
{
    self.backgroundColor = [Utils colorWithRGBHex:0xf0f0f0];
    
    isChange = NO;
    artwork = nil;
}

@end

//
//  ListSongCell.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/31/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "ListSongCell.h"

#import "Item.h"

#import "Utils.h"

#import "VYPlayIndicator.h"
#import "UIImageView+WebCache.h"

@interface ListSongCell()
{
    UIColor *bgColor, *highlightColor;
    UIImage *iTunesIcon, *cloudIcon;
}

@property (nonatomic, weak) IBOutlet UIView *vContent;
@property (nonatomic, weak) IBOutlet UILabel *lblIndex, *lblSongName, *lblDuration;
@property (nonatomic, weak) IBOutlet UIImageView *imgvIcon;

@property (nonatomic, weak) IBOutlet UIView *vMusicEq;
@property (nonatomic, strong) VYPlayIndicator *musicEq;

@property (nonatomic, weak) IBOutlet UIView *line;

@end

@implementation ListSongCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    self.lblDuration.textColor = [Utils colorWithRGBHex:0x545454];
    
    iTunesIcon = [UIImage imageNamed:@"ipod-item-icon"];
    cloudIcon = [UIImage imageNamed:@"cloud-item-icon"];
    
    bgColor = [UIColor whiteColor];
    highlightColor = [Utils colorWithRGBHex:0xe4f2ff];
}

- (void)setIndex:(NSIndexPath *)indexPath
{
    self.lblIndex.text = [NSString stringWithFormat:@"%d",(int)indexPath.row + 1];
}

- (void)config:(Item *)item
{
    self.lblSongName.text = item.sSongName;
    self.lblDuration.text = item.sDuration;
    self.imgvIcon.image = item.isCloud.boolValue ? cloudIcon:iTunesIcon;
}

+ (CGFloat)height
{
    return 48.0;
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

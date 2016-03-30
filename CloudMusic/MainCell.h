//
//  MainCell.h
//  CloudMusic
//
//  Created by TuanTN on 3/30/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VYPlayIndicator;

#import "MGSwipeTableCell.h"

@interface MainCell : MGSwipeTableCell

@property (nonatomic, weak) IBOutlet UIImageView *imgvArtwork;

@property (nonatomic, weak) IBOutlet UIView *vContent;
@property (nonatomic, weak) IBOutlet UIView *line;

@property (nonatomic, weak) IBOutlet UIView *vMusicEq;
@property (nonatomic, strong) VYPlayIndicator *musicEq;

@property (nonatomic, weak) IBOutlet UIImageView *imgvIcon;

- (void)config:(id)item;

- (void)setItemType:(BOOL)isCloud;
- (void)setArtwork:(NSURL *)sArtworkUrl;
- (void)setLineHidden:(BOOL)isHidden;
- (void)isPlaying:(BOOL)isPlaying;

@end

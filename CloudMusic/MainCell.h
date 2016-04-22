//
//  MainCell.h
//  CloudMusic
//
//  Created by TuanTN on 3/30/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VYPlayIndicator;
@class Playlist;

@protocol MainCellDelegate <NSObject>

- (void)changePlaylistName:(Playlist *)playlist;

@end

#import "MGSwipeTableCell.h"

@interface MainCell : MGSwipeTableCell

@property (nonatomic, weak) IBOutlet UIImageView *imgvArtwork;

@property (nonatomic, weak) IBOutlet UIView *vContent;
@property (nonatomic, weak) IBOutlet UIView *line;

@property (nonatomic, weak) IBOutlet UIView *vMusicEq;
@property (nonatomic, strong) VYPlayIndicator *musicEq;

@property (nonatomic, weak) IBOutlet UIImageView *imgvIcon;
@property (nonatomic, weak) IBOutlet UIImageView *imgvListIcon;

@property (nonatomic, assign) id<MainCellDelegate> subDelegate;

+ (CGFloat)normalCellHeight;
+ (CGFloat)largeCellHeight;

- (void)config:(id)item;
- (void)configWithoutMenu:(id)item;

- (void)setItemType:(BOOL)isCloud;
- (void)setArtwork:(NSURL *)sArtworkUrl;

- (void)configMenuButton:(BOOL)isCloud isEdit:(BOOL)isEdit hasIndexTitle:(BOOL)hasIndexTitle;
- (void)configLeftMenu:(BOOL)isCloud isEdit:(BOOL)isEdit;
- (void)configRightMenu:(BOOL)isDelete hasIndexTitle:(BOOL)hasIndexTitle;

- (void)setLineHidden:(BOOL)isHidden;
- (void)isPlaying:(BOOL)isPlaying;

@end

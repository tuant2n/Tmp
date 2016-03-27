//
//  AlbumsCell.h
//  CloudMusic
//
//  Created by TuanTN on 3/26/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@class AlbumObj;

@interface AlbumsCell : MGSwipeTableCell

- (void)config:(AlbumObj *)item;
- (void)setLineHidden:(BOOL)isHidden;
- (void)isPlaying:(BOOL)isPlaying;

+ (CGFloat)height;

@end

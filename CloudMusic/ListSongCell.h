//
//  ListSongCell.h
//  CloudMusic
//
//  Created by TuanTN8 on 3/31/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@class Item;

@interface ListSongCell : MGSwipeTableCell

- (void)setIndex:(NSIndexPath *)indexPath;
- (void)config:(Item *)item;
+ (CGFloat)height;

- (void)setLineHidden:(BOOL)isHidden;
- (void)isPlaying:(BOOL)isPlaying;

@end

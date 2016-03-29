//
//  GenresCell.h
//  CloudMusic
//
//  Created by TuanTN on 3/28/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@class GenreObj;

@interface GenresCell : MGSwipeTableCell

- (void)config:(GenreObj *)item;
- (void)setLineHidden:(BOOL)isHidden;
- (void)isPlaying:(BOOL)isPlaying;

+ (CGFloat)height;

@end

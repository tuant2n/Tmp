//
//  SongsCell.h
//  CloudMusic
//
//  Created by TuanTN8 on 3/25/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@class Item;

@interface SongsCell : MGSwipeTableCell

- (void)configWithItem:(Item *)item;
- (void)setLineHidden:(BOOL)isHidden;

+ (CGFloat)height;

@end

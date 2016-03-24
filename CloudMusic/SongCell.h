//
//  SongCell.h
//  CloudMusic
//
//  Created by TuanTN8 on 3/24/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;

@interface SongCell : UITableViewCell

- (void)configWithItem:(Item *)item;
- (void)setLineHidden:(BOOL)isHidden;

+ (CGFloat)height;

@end

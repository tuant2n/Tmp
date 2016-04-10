//
//  DropBoxFileCell.h
//  CloudMusic
//
//  Created by TuanTN on 4/9/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DropBoxObj;

@interface DropBoxFileCell : UITableViewCell

@property (nonatomic, strong) DropBoxObj *currentItem;

- (void)configWithItem:(DropBoxObj *)item;
- (void)setIsSelected:(BOOL)isCheck;

- (void)addObserver;
- (void)removeObserver;

+ (CGFloat)height;

@end

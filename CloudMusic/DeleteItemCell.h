//
//  DeleteSongCell.h
//  CloudMusic
//
//  Created by TuanTN on 4/17/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DeleteItemCellDelegate <NSObject>

- (void)deleteItem;

@end

@interface DeleteItemCell : UITableViewCell

@property (nonatomic, assign) id<DeleteItemCellDelegate> delegate;

+ (CGFloat)height;

@end

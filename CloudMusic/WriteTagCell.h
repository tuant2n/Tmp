//
//  TagRadioButton.h
//  CloudMusic
//
//  Created by TuanTN on 4/4/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WriteTagCell;

@protocol WriteTagCellDelegate <NSObject>

- (void)changeActionWriteTags:(WriteTagCell *)cell;

@end

@interface WriteTagCell : UITableViewCell

@property (nonatomic, assign) id<WriteTagCellDelegate> delegate;;

- (void)configWithValue:(BOOL)isCheck;

@end

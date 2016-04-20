//
//  TagCell.h
//  CloudMusic
//
//  Created by TuanTN8 on 4/2/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TagObj;

@protocol TagElementCellDelegate <NSObject>
- (void)disableSave;
@end

@interface TagElementCell : UITableViewCell

@property (nonatomic, assign) id<TagElementCellDelegate> delegate;
@property (nonatomic, strong) TagObj *tagObj;

- (void)configWithTag:(TagObj *)tagObj;
- (void)setHiddenLine:(BOOL)isHidden;

+ (CGFloat)height;

@end

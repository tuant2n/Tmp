//
//  TagRenameCell.h
//  CloudMusic
//
//  Created by TuanTN on 4/17/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TagObj;
@class TagRenameCell;

@protocol TagRenameCellDelegate <NSObject>

- (void)copyTitleToFileName:(TagRenameCell *)cell;

@end

@interface TagRenameCell : UITableViewCell

@property (nonatomic, strong) TagObj *tagObj;
@property (nonatomic, assign) id<TagRenameCellDelegate> delegate;

- (void)configWithTag:(TagObj *)tagObj;
- (void)setFileName:(NSString *)sName;

+ (CGFloat)height;

@end

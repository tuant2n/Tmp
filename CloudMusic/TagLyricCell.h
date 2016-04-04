//
//  TagLyricCell.h
//  CloudMusic
//
//  Created by TuanTN on 4/4/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TagObj;

@interface TagLyricCell : UITableViewCell

@property (nonatomic, strong) TagObj *tagObj;

- (void)configWithTag:(TagObj *)tagObj;

+ (CGFloat)height;

@end

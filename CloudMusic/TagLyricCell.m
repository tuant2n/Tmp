//
//  TagLyricCell.m
//  CloudMusic
//
//  Created by TuanTN on 4/4/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "TagLyricCell.h"

#import "TagObj.h"

@interface TagLyricCell()
{
    
}

@property (nonatomic, weak) IBOutlet UITextView *tvLyric;

@end

@implementation TagLyricCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)configWithTag:(TagObj *)tagObj
{
    self.tagObj = tagObj;
    self.tvLyric.text = self.tagObj.value;
}

+ (CGFloat)height
{
    return 104.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
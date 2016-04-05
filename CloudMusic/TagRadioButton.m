//
//  TagRadioButton.m
//  CloudMusic
//
//  Created by TuanTN on 4/4/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "TagRadioButton.h"

#import "Utils.h"

@interface TagRadioButton()
{
    UIImage *check, *uncheck;
    UIColor *bgColor, *highlightColor;
}

@property (nonatomic, weak) IBOutlet UIView *vBackground;
@property (nonatomic, weak) IBOutlet UIImageView *imgvCheck;

@end

@implementation TagRadioButton

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    check = [UIImage imageNamed:@"check"];
    uncheck = [UIImage imageNamed:@"uncheck"];
    
    bgColor = [UIColor whiteColor];
    highlightColor = [Utils colorWithRGBHex:0xe4f2ff];
}

- (void)configWithValue:(BOOL)isCheck
{
    self.imgvCheck.image = isCheck ? check:uncheck;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted)
    {
        self.vBackground.backgroundColor = highlightColor;
    }
    else {
        self.vBackground.backgroundColor = bgColor;
    }
}

@end

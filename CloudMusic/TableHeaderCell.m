//
//  TableHeaderCell.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/25/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "TableHeaderCell.h"

#import "Utils.h"

#import "HeaderUtilObj.h"

@interface TableHeaderCell()
{
    UIColor *bgColor, *highlightColor;
}

@property (nonatomic, weak) IBOutlet UIView *bgView;
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UIImageView *imgvIcon;
@property (nonatomic, weak) IBOutlet UIView *line;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imgvIconLayout;

@end

@implementation TableHeaderCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    
    bgColor = [UIColor whiteColor];
    highlightColor = [Utils lighterColorForColor:[UIColor lightGrayColor] andDelta:0.3];
}

- (void)configWithUtil:(HeaderUtilObj *)utilObj hasIndexTitles:(BOOL)isTrue
{
    self.lblTitle.text = utilObj.sTitle;
    self.imgvIcon.image = utilObj.icon;
    
    if (isTrue) {
        self.imgvIconLayout.constant = 15.0;
    }
    else {
        self.imgvIconLayout.constant = 5.0;
    }
}

- (void)setLineHidden:(BOOL)isHidden
{
    self.line.hidden = isHidden;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted)
    {
        self.bgView.backgroundColor = highlightColor;
    }
    else {
        self.bgView.backgroundColor = bgColor;
    }
}

+ (CGFloat)height
{
    return 37.0;
}

@end

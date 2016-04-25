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

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imgvIconLayout;

@end

@implementation TableHeaderCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
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
        self.imgvIconLayout.constant = 10.0;
    }
    
    if (utilObj.iType == kHeaderUtilTypeAddAllSongs) {
        self.lblTitle.textColor = [UIColor blackColor];
        self.lblTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:17.0];
    }
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
    return 40.0;
}

@end

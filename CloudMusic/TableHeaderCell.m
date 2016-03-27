//
//  TableHeaderCell.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/25/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "TableHeaderCell.h"

#import "HeaderUtilObj.h"

@interface TableHeaderCell()

@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UIImageView *imgvIcon;

@end

@implementation TableHeaderCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)configWithUtil:(HeaderUtilObj *)utilObj
{
    self.lblTitle.text = utilObj.sTitle;
    self.imgvIcon.image = utilObj.icon;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (CGFloat)height
{
    return 44.0;
}

@end

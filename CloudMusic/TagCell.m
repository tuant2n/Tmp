//
//  TagCell.m
//  CloudMusic
//
//  Created by TuanTN8 on 4/2/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "TagCell.h"

#import "Utils.h"

@interface TagCell()
{
    
}

@property (nonatomic, weak) IBOutlet UILabel *lblTagName;
@property (nonatomic, weak) IBOutlet UITextField *tfTagContent;
@property (nonatomic, weak) IBOutlet UIView *line;

@end

@implementation TagCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    self.lblTagName.textColor = [Utils colorWithRGBHex:0x006bd5];
}

+ (CGFloat)height
{
    return 44.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

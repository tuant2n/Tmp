//
//  TagButton.m
//  CloudMusic
//
//  Created by TuanTN on 4/4/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "TagButton.h"

#import "Utils.h"

@interface TagButton()
{
    UIColor *bgColor, *highlightColor;
}

@property (nonatomic, weak) IBOutlet UIView *vBackground;
@property (nonatomic, weak) IBOutlet UILabel *lblButtonTitle;

@end

@implementation TagButton

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    bgColor = [UIColor whiteColor];
    highlightColor = [Utils colorWithRGBHex:0xe4f2ff];
}

- (void)configWithActionType:(kTagActionType)iActionType
{
    if (iActionType == kTagActionTypeWriteTitle) {
        self.lblButtonTitle.text = @"Copy Title to Filename";
        self.lblButtonTitle.textColor = [UIColor blackColor];
    }
    else if (iActionType == kTagActionTypeDelete) {
        self.lblButtonTitle.text = @"Delete";
        self.lblButtonTitle.textColor = [UIColor redColor];
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
        self.vBackground.backgroundColor = highlightColor;
    }
    else {
        self.vBackground.backgroundColor = bgColor;
    }
}

@end

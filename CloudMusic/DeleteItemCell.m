//
//  DeleteSongCell.m
//  CloudMusic
//
//  Created by TuanTN on 4/17/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "DeleteItemCell.h"

@implementation DeleteItemCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (IBAction)touchDelete:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(deleteItem)]) {
        [self.delegate deleteItem];
    }
}

+ (CGFloat)height
{
    return 44.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

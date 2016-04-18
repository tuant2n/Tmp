//
//  TagRadioButton.m
//  CloudMusic
//
//  Created by TuanTN on 4/4/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "WriteTagCell.h"

#import "Utils.h"

@interface WriteTagCell()
{
    UIImage *check, *uncheck;
}

@property (nonatomic, weak) IBOutlet UIImageView *imgvCheck;

@end

@implementation WriteTagCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    check = [UIImage imageNamed:@"check"];
    uncheck = [UIImage imageNamed:@"uncheck"];
}

- (void)configWithValue:(BOOL)isCheck
{
    self.imgvCheck.image = isCheck ? check:uncheck;
}

- (IBAction)touchSetActionWriteTags:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(changeActionWriteTags:)]) {
        [self.delegate changeActionWriteTags:self];
    }
}

@end

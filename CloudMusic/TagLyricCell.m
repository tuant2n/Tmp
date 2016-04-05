//
//  TagLyricCell.m
//  CloudMusic
//
//  Created by TuanTN on 4/4/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "TagLyricCell.h"

#import "TagObj.h"

@interface TagLyricCell() <UITextViewDelegate>
{
    
}

@property (nonatomic, weak) IBOutlet UITextView *tvLyric;

@end

@implementation TagLyricCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.tvLyric.delegate = self;
    self.tvLyric.contentInset = UIEdgeInsetsMake(-8.0, 0.0, 0.0, 0.0);
}

- (void)configWithTag:(TagObj *)tagObj
{
    self.tagObj = tagObj;
    self.tvLyric.text = self.tagObj.value;
}

+ (CGFloat)height
{
    return 175.0;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.tagObj.iTagType == kTagTypeElement) {
        self.tagObj.value = textView.text;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

//
//  TagLyricCell.m
//  CloudMusic
//
//  Created by TuanTN on 4/4/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "TagLyricCell.h"

#import "TagObj.h"
#import "Utils.h"

@interface TagLyricCell() <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextView *tvLyric;
@property (nonatomic, weak) IBOutlet UIView *line;

@end

@implementation TagLyricCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    self.tvLyric.delegate = self;
    self.tvLyric.contentInset = UIEdgeInsetsMake(-8.0, 0.0, 0.0, 0.0);
}

- (void)configWithTag:(TagObj *)tagObj
{
    self.tagObj = tagObj;
    self.tvLyric.text = self.tagObj.value;
}

- (IBAction)touchClearLyrics:(id)sender
{
    self.tagObj.value = nil;
    self.tvLyric.text = nil;
}

+ (CGFloat)height
{
    return 185.0;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.tagObj.iTagType == kTagTypeLyrics) {
        self.tagObj.value = textView.text;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

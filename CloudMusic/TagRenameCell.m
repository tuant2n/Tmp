//
//  TagRenameCell.m
//  CloudMusic
//
//  Created by TuanTN on 4/17/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "TagRenameCell.h"

#import "TagObj.h"
#import "Utils.h"

@interface TagRenameCell() <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *tfFileName;
@property (nonatomic, weak) IBOutlet UILabel *lblTagName;

@property (nonatomic, weak) IBOutlet UIView *line;

@end

@implementation TagRenameCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.lblTagName.textColor = [Utils colorWithRGBHex:0x006bd5];
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    
    self.tfFileName.delegate = self;
}

- (void)configWithTag:(TagObj *)tagObj
{
    self.tagObj = tagObj;
    [self setFileName:self.tagObj.value];
}

- (void)setFileName:(NSString *)sName
{
    self.tfFileName.text = sName;
}

- (IBAction)touchCopyTitle:(id)sender
{
    if (!self.tagObj) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(copyTitleToFileName:)]) {
        [self.delegate copyTitleToFileName:self];
    }
}

+ (CGFloat)height
{
    return 84.0;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *sTmp = textField.text;
    if (sTmp.length > 0) {
        self.tagObj.value = sTmp;
    }
    else {
        textField.text = self.tagObj.value;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

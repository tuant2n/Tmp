//
//  TagCell.m
//  CloudMusic
//
//  Created by TuanTN8 on 4/2/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "TagElementCell.h"

#import "TagObj.h"
#import "Utils.h"

@interface TagElementCell() <UITextFieldDelegate>
{
    
}

@property (nonatomic, weak) IBOutlet UILabel *lblTagName;
@property (nonatomic, weak) IBOutlet UITextField *tfTagContent;
@property (nonatomic, weak) IBOutlet UIView *line;

@end

@implementation TagElementCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    self.lblTagName.textColor = [Utils colorWithRGBHex:0x006bd5];
    
    self.tfTagContent.delegate = self;
}

- (void)configWithTag:(TagObj *)tagObj
{
    self.tagObj = tagObj;
    
    [self setTagName];
    self.tfTagContent.text = self.tagObj.value;

    if (!self.tagObj.isEditable) {
        self.tfTagContent.textColor = [UIColor lightGrayColor];
        self.tfTagContent.userInteractionEnabled = NO;
    }
    else {
        self.tfTagContent.textColor = [UIColor blackColor];
        self.tfTagContent.userInteractionEnabled = YES;
    }
}

- (void)setHiddenLine:(BOOL)isHidden
{
    self.line.hidden = isHidden;
}

+ (CGFloat)height
{
    return 44.0;
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

#pragma mark - Utils

- (void)setTagName
{
    switch (self.tagObj.iElementType)
    {
        case kElementTypeTitle:
            self.lblTagName.text = @"Title";
            self.tfTagContent.placeholder = @"Title";
            break;
            
        case kElementTypeArtist:
            self.lblTagName.text = @"Artist";
            self.tfTagContent.placeholder = @"Artist";
            break;
            
        case kElementTypeAlbumArtist:
            self.lblTagName.text = @"Album Artist";
            self.tfTagContent.placeholder = @"Album Artist";
            break;
            
        case kElementTypeAlbum:
            self.lblTagName.text = @"Album";
            self.tfTagContent.placeholder = @"Album";
            break;
            
        case kElementTypeYear:
            self.lblTagName.text = @"Year";
            self.tfTagContent.placeholder = @"Year";
            break;
            
        case kElementTypeGenre:
            self.lblTagName.text = @"Genre";
            self.tfTagContent.placeholder = @"Genre";
            break;
            
        case kElementTypeTime:
            self.lblTagName.text = @"Time";
            self.tfTagContent.placeholder = @"Time";
            break;
            
        case kElementTypeSize:
            self.lblTagName.text = @"Size";
            self.tfTagContent.placeholder = @"Size";
            break;
            
        case kElementTypePlayed:
            self.lblTagName.text = @"Played";
            self.tfTagContent.placeholder = @"Played";
            break;
            
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

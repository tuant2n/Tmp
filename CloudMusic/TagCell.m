//
//  TagCell.m
//  CloudMusic
//
//  Created by TuanTN8 on 4/2/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "TagCell.h"

#import "TagObj.h"
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
            
        case kElementTypeTrack:
            self.lblTagName.text = @"Track";
            self.tfTagContent.placeholder = @"Track";
            break;
            
        case kElementTypeYear:
            self.lblTagName.text = @"Year";
            self.tfTagContent.placeholder = @"Year";
            break;
            
        case kElementTypeGenre:
            self.lblTagName.text = @"Genre";
            self.tfTagContent.placeholder = @"Genre";
            break;
            
        case kElementTypeFolderName:
            self.lblTagName.text = @"Folder";
            self.tfTagContent.placeholder = @"Folder";
            break;
            
        case kElementTypeFilename:
            self.lblTagName.text = @"Filename";
            self.tfTagContent.placeholder = @"Filename";
            break;
            
        case kElementTypeTime:
            self.lblTagName.text = @"Time";
            self.tfTagContent.placeholder = @"Time";
            break;
        
        case kElementTypeKind:
            self.lblTagName.text = @"Kind";
            self.tfTagContent.placeholder = @"Kind";
            break;
            
        case kElementTypeSize:
            self.lblTagName.text = @"Size";
            self.tfTagContent.placeholder = @"Size";
            break;
            
        case kElementTypeBitRate:
            self.lblTagName.text = @"Bit Rate";
            self.tfTagContent.placeholder = @"Bit Rate";
            break;
            
        case kElementTypePlayed:
            self.lblTagName.text = @"Played";
            self.tfTagContent.placeholder = @"Played";
            break;
            
        default:
            break;
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

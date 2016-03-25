//
//  SongHeaderTitle.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/24/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "SongHeaderTitle.h"

#import "Utils.h"

@interface SongHeaderTitle()

@property (nonatomic, weak) IBOutlet UILabel *lblTitle;

@end

@implementation SongHeaderTitle

- (void)awakeFromNib
{
    self.lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0];
    self.lblTitle.textColor = [Utils colorWithRGBHex:0x9c9c9c];
    
    self.contentView.backgroundColor = [Utils colorWithRGBHex:0xf7f7f7];
}

- (void)setTitle:(NSString *)sTitle
{
    self.lblTitle.text = sTitle;
}

+ (CGFloat)height
{
    return 20.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

//
//  SongHeaderTitle.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/24/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "HeaderTitle.h"

#import "Utils.h"

@interface HeaderTitle()

@property (nonatomic, weak) IBOutlet UILabel *lblTitle;

@end

@implementation HeaderTitle

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
    return 23.0;
}

@end

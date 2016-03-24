//
//  TableFooterCell.m
//  CloudMusic
//
//  Created by TuanTN on 3/24/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "TableFooterCell.h"

#import "Utils.h"

@interface TableFooterCell()

@property (nonatomic, weak) IBOutlet UIView *line;
@property (nonatomic, weak) IBOutlet UILabel *lblContent;

@end

@implementation TableFooterCell

- (void)awakeFromNib
{
    self.contentView.backgroundColor = [UIColor clearColor];
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    
    self.lblContent.textColor = [Utils colorWithRGBHex:0x6a6a6a];
    self.lblContent.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
}

- (void)setContent:(NSString *)sContent
{
    self.lblContent.text = sContent;
}

@end

//
//  TableFooterView.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/25/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "TableFooterView.h"

#import "Utils.h"

@interface TableFooterView()

@property (nonatomic, weak) IBOutlet UIView *line;
@property (nonatomic, weak) IBOutlet UILabel *lblContent;

@end

@implementation TableFooterView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    
    self.lblContent.textColor = [Utils colorWithRGBHex:0x6a6a6a];
    self.lblContent.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
}

- (void)setContent:(NSString *)sContent
{
    self.lblContent.text = sContent;
}

@end

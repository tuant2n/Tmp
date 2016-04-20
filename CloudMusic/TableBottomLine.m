//
//  TableBottomLine.m
//  CloudMusic
//
//  Created by TuanTN8 on 4/20/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "TableBottomLine.h"

#import "Utils.h"

@interface TableBottomLine()

@property (nonatomic, strong) IBOutlet UIView *line;

@end

@implementation TableBottomLine

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
}

@end

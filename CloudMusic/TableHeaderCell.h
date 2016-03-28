//
//  TableHeaderCell.h
//  CloudMusic
//
//  Created by TuanTN8 on 3/25/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HeaderUtilObj;

@interface TableHeaderCell : UITableViewCell

- (void)configWithUtil:(HeaderUtilObj *)utilObj hasIndexTitles:(BOOL)isTrue;

+ (CGFloat)height;

@end

//
//  HeaderUtilObj.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/25/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "HeaderUtilObj.h"

@implementation HeaderUtilObj

- (id)initWithTitle:(NSString *)sTitle icon:(NSString *)sIconName type:(kHeaderUtilType)iType
{
    self = [super init];
    
    if (self) {
        _sTitle = sTitle;
        _iType = iType;
        _icon = [UIImage imageNamed:sIconName];
    }
    
    return self;
}

@end

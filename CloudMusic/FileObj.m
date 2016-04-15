//
//  FileObj.m
//  CloudMusic
//
//  Created by TuanTN8 on 4/15/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "FileObj.h"

#import "Item.h"

@implementation FileObj

- (id)initWithItem:(Item *)item
{
    self = [super init];
    
    if (self) {
        _item = item;
    }
    
    return self;
}

@end

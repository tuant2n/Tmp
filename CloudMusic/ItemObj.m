//
//  ItemObj.m
//  CloudMusic
//
//  Created by TuanTN8 on 4/21/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "ItemObj.h"

#import "Item.h"

@implementation ItemObj

- (id)initWithSong:(Item *)song
{
    self = [super init];
    
    if (self) {
        _song = song;
    }
    
    return self;
}

@end

//
//  ItemObj.h
//  CloudMusic
//
//  Created by TuanTN8 on 4/21/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;

@interface ItemObj : NSObject

@property (nonatomic, strong) Item *song;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) int numberOfSelect;

- (id)initWithSong:(Item *)song;

@end

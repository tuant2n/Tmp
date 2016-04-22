//
//  AddSongsCell.h
//  CloudMusic
//
//  Created by TuanTN8 on 4/22/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainCell.h"

@class Item;

@interface AddSongsCell : MainCell

@property (nonatomic, strong) Item *currentSong;

- (void)addObserver;
- (void)removeObserver;

@end

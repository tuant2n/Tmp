//
//  CurrentSongCollectionCell.h
//  CloudMusic
//
//  Created by TuanTN on 4/27/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;

@interface CurrentSongCollectionCell : UICollectionViewCell

- (void)configWithSong:(Item *)song;

@end

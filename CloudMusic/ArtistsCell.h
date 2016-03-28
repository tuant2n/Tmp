//
//  ArtistsCell.h
//  CloudMusic
//
//  Created by TuanTN8 on 3/28/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

#import "AlbumArtistObj.h"

@interface ArtistsCell : MGSwipeTableCell

- (void)config:(AlbumArtistObj *)item;
- (void)setLineHidden:(BOOL)isHidden;
- (void)isPlaying:(BOOL)isPlaying;

+ (CGFloat)height;


@end

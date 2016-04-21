//
//  PlaylistCell.h
//  CloudMusic
//
//  Created by TuanTN on 4/20/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainCell.h"

@class Playlist;

@interface PlaylistCell : MainCell

- (void)configWithPlaylist:(Playlist *)playlist;

+ (CGFloat)heigth;

@end

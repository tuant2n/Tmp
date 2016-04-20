//
//  PlaylistCell.h
//  CloudMusic
//
//  Created by TuanTN on 4/18/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainCell.h"

@class Playlist;

@interface PlaylistsCell : MainCell

@property (nonatomic, strong) Playlist *currentPlaylist;

@end
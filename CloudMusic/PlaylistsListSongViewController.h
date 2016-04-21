//
//  PlaylistsListSongViewController.h
//  CloudMusic
//
//  Created by TuanTN8 on 4/20/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Playlist;

@interface PlaylistsListSongViewController : UIViewController

@property (nonatomic, strong) Playlist *currentPlaylist;

@end

//
//  PlayerViewController.h
//  CloudMusic
//
//  Created by TuanTN8 on 3/10/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;

@interface PlayerViewController : UIViewController

+ (PlayerViewController *)sharedInstance;

- (void)playWithPlaylist:(NSArray *)listSongs isShuffle:(BOOL)isShuffle;
- (void)playWithSong:(Item *)song;

@end

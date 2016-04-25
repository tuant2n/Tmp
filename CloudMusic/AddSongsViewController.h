//
//  AddSongsViewController.h
//  CloudMusic
//
//  Created by TuanTN8 on 4/22/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Playlist;

@protocol AddSongsViewControllerDelegate <NSObject>

- (void)getNewPlaylistItems:(NSArray *)newPlaylistItem;

@end

@interface AddSongsViewController : UIViewController

@property (nonatomic, assign) id<AddSongsViewControllerDelegate> delegate;
@property (nonatomic, strong) Playlist *currentPlaylist;
@property (nonatomic, strong) NSMutableArray *currentListSongs;

@end

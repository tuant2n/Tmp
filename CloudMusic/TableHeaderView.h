//
//  TableHeaderView.h
//  CloudMusic
//
//  Created by TuanTN on 3/24/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kHeaderUtilTypeShuffle,
    kHeaderUtilTypeShuffleFromSong,
    kHeaderUtilTypeGoAllAlbums,
    kHeaderUtilTypeGoAllSongs,
    kHeaderUtilTypeCreatePlaylistWithData,
    kHeaderUtilTypeCreateNewPlaylist,
    kHeaderUtilTypeAddAllSongs,
    kHeaderUtilTypeFilter
} kHeaderUtilType;

@class AlbumObj;

@protocol TableHeaderViewDelegate <NSObject>

- (void)selectUtility:(kHeaderUtilType)iType;

@end

@interface TableHeaderView : UIView

@property (nonatomic, assign) id<TableHeaderViewDelegate> delegate;
@property (nonatomic, strong) UISearchBar *searchBar;

- (id)initForFilesVC;
- (id)initForSongsVC;
- (id)initForAlbumsVC;
- (id)initForArtistsVC;
- (id)initForGenresVC;
- (id)initForPlaylistsVC;
- (id)initForPlaylistsListSongVC;

- (id)initForAlbumListVC:(AlbumObj *)album;
- (id)initForAddSongsVC;

- (void)resignKeyboard;

@end

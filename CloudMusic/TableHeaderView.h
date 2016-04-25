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

#define SEARCHBAR_HEIGHT 44.0
#define LINE_SEPERATOR_HEIGHT 1

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

@end

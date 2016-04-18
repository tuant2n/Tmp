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
    kHeaderUtilTypeGoAllAlbums,
    kHeaderUtilTypeGoAllSongs,
    kHeaderUtilTypeCreatePlaylist,
    kHeaderUtilTypeCreateNewPlaylist,
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

- (id)initForAlbumListVC:(AlbumObj *)album;

- (void)resignKeyboard;

@end

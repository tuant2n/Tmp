//
//  TableHeaderView.h
//  CloudMusic
//
//  Created by TuanTN on 3/24/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kHeaderUtilTypeEdit = 0,
    kHeaderUtilTypeShuffle = 1,
    kHeaderUtilTypeGoAllAlbums = 2,
    kHeaderUtilTypeGoAllSongs = 3,
    kHeaderUtilTypeCreatePlaylist = 4,
} kHeaderUtilType;

@class AlbumObj;

@protocol TableHeaderViewDelegate <NSObject>

- (void)selectUtility:(kHeaderUtilType)iType;

@end

@interface TableHeaderView : UIView

@property (nonatomic, assign) id<TableHeaderViewDelegate> delegate;
@property (nonatomic, strong) UISearchBar *searchBar;

- (id)initForSongsVC;
- (id)initForAlbumsVC;
- (id)initForArtistsVC;
- (id)initForGenresVC;
- (id)initForAlbumListVC:(AlbumObj *)album;

- (float)getHeight;
- (void)resignKeyboard;

@end

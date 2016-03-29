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

- (float)getHeight;
- (void)setActiveSearchBar:(BOOL)isActive;
- (void)resignKeyboard;

@end

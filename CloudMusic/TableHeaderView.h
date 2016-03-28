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
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

- (void)setupForSongsVC;
- (void)setupForAlbumVC;
- (void)setupForArtistVC;
- (void)setupForGenreVC;

- (void)setActiveSearchBar:(BOOL)isActive;
- (void)setHeight:(float)fHeight;

@end

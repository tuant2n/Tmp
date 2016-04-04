//
//  DataManagement.h
//  CloudMusic
//
//  Created by TuanTN8 on 3/19/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HCDCoreDataStackController.h"

#import "Item.h"
#import "FileInfo.h"

#import "AlbumObj.h"
#import "AlbumArtistObj.h"
#import "GenreObj.h"
#import "DataObj.h"

#import "MainCell.h"
#import "SongsCell.h"
#import "AlbumsCell.h"
#import "ArtistsCell.h"
#import "GenresCell.h"
#import "HeaderTitle.h"
#import "ListSongCell.h"

#import "SongsViewController.h"
#import "AlbumsViewController.h"
#import "AlbumListViewController.h"
#import "ArtistsViewController.h"
#import "GenresViewController.h"

#import "SearchOperation.h"

@interface DataManagement : NSObject

+ (DataManagement *)sharedInstance;

@property (nonatomic, strong) HCDCoreDataStackController *coreDataController;

- (NSManagedObjectContext *)managedObjectContext;
- (NSEntityDescription *)itemEntity;
- (NSEntityDescription *)fileInfoEntity;

#pragma mark - Data Method

- (void)removeAllData;
- (void)syncData;
- (void)saveData;

- (NSFetchRequest *)getListSongFilterByName:(NSString *)sName albumId:(NSString *)iAlbumId artistId:(NSString *)iArtistId genreId:(NSString *)iGenreId;

- (NSArray *)getListSongFilterByName:(NSString *)sName;
- (NSArray *)getListSongCloudFilterByName:(NSString *)sName;
- (NSArray *)getListAlbumFilterByName:(NSString *)sName albumArtistId:(NSString *)iAlbumArtistId genreId:(NSString *)iGenreId;
- (NSArray *)getListAlbumArtistFilterByName:(NSString *)sName;
- (NSArray *)getListGenreFilterByName:(NSString *)sName;

#pragma mark - Search

- (void)search:(NSString *)sSearch searchType:(kSearchType)iSearchType block:(void (^)(NSArray *results))block;
- (void)cancelSearch;

#pragma mark - DoAction

- (void)doActionWithItem:(id)item fromNavigation:(UINavigationController *)navController;

#pragma mark - iTunes Sync

- (void)setLastTimeAppSync:(long)lTime;
- (long)getLastTimeAppSync;

@end

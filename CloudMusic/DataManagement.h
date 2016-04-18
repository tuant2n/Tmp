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
#import "Playlist.h"

#import "AlbumObj.h"
#import "AlbumArtistObj.h"
#import "GenreObj.h"
#import "DataObj.h"

#import "FileObj.h"
#import "DropBoxObj.h"

#import "SongsViewController.h"
#import "AlbumsViewController.h"
#import "AlbumListViewController.h"
#import "ArtistsViewController.h"
#import "GenresViewController.h"

#import "EditViewController.h"
#import "AddToPlaylistViewController.h"
#import "MakePlaylistViewController.h"

#import "SearchOperation.h"

@interface DataManagement : NSObject

+ (DataManagement *)sharedInstance;

@property (nonatomic, strong) HCDCoreDataStackController *coreDataController;

- (NSManagedObjectContext *)managedObjectContext;
- (NSEntityDescription *)itemEntity;
- (NSEntityDescription *)fileInfoEntity;
- (NSEntityDescription *)playlistEntity;

#pragma mark - Data Method

- (void)syncDataWithBlock:(void (^)(bool isSuccess))block;

- (void)saveData;
- (void)saveData:(BOOL)isNotify;

- (void)insertSong:(DropBoxObj *)DropBoxObj;

- (NSFetchRequest *)getListSongFilterByName:(NSString *)sName albumId:(NSString *)iAlbumId artistId:(NSString *)iArtistId genreId:(NSString *)iGenreId;
- (NSArray *)getListSongFilterByName:(NSString *)sName;
- (NSArray *)getListSongCloudFilterByName:(NSString *)sName;
- (NSArray *)getListAlbumFilterByName:(NSString *)sName albumArtistId:(NSString *)iAlbumArtistId genreId:(NSString *)iGenreId;
- (NSArray *)getListAlbumArtistFilterByName:(NSString *)sName;
- (NSArray *)getListGenreFilterByName:(NSString *)sName;

- (Item *)getItemBySongId:(NSString *)iSongId;
- (NSString *)getAlbumIdFromName:(NSString *)sAlbumName;
- (NSString *)getAlbumArtistIdFromName:(NSString *)sAlbumArtistName;
- (NSString *)getArtistIdFromName:(NSString *)sArtistName;
- (NSString *)getGenreIdFromName:(NSString *)sGenreName;

- (void)deleteSong:(Item *)item;
- (void)deleteAlbum:(AlbumObj *)album;
- (void)deleteArtist:(AlbumArtistObj *)artist;
- (void)deleteGenre:(GenreObj *)genre;

#pragma mark - Playlist

- (Playlist *)getPlaylistWithType:(kPlaylistType)iPlaylistType andName:(NSString *)sName;
- (NSFetchRequest *)getListPlaylistIsGetNormalOnly:(BOOL)isNormalOnly;
- (void)removeItemFromPlaylist:(Item *)item;
- (void)addItem:(Item *)item toSpecialList:(kPlaylistType)iPlaylistType;

#pragma mark - Search

- (void)search:(NSString *)sSearch searchType:(kSearchType)iSearchType block:(void (^)(NSArray *results))block;
- (void)cancelSearch;

#pragma mark - DoAction

- (void)doActionWithItem:(id)item fromNavigation:(UINavigationController *)navController;
- (BOOL)doSwipeActionWithItem:(id)item atIndex:(NSInteger)index fromNavigation:(UINavigationController *)navController;
- (void)doUtility:(int)iType withData:(NSArray *)arrData fromNavigation:(UINavigationController *)navController;

#pragma mark - iTunes Sync

- (void)setLastTimeAppSync:(long)lTime;
- (long)getLastTimeAppSync;

@end

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
#import "File.h"
#import "Playlist.h"

#import "AlbumObj.h"
#import "AlbumArtistObj.h"
#import "GenreObj.h"
#import "DataObj.h"
#import "DropBoxObj.h"

#import "SongsViewController.h"
#import "AlbumsViewController.h"
#import "AlbumListViewController.h"
#import "ArtistsViewController.h"
#import "GenresViewController.h"

#import "EditViewController.h"
#import "CreatePlaylistViewController.h"
#import "MakePlaylistViewController.h"
#import "PlaylistsListSongViewController.h"

#import "PlayerViewController.h"

#import "SearchOperation.h"
#import "NSManagedObject+Clone.h"

@interface DataManagement : NSObject

+ (DataManagement *)sharedInstance;

@property (nonatomic, strong) HCDCoreDataStackController *coreDataController;

- (NSManagedObjectContext *)managedObjectContext;
- (NSEntityDescription *)itemEntity;
- (NSEntityDescription *)fileEntity;
- (NSEntityDescription *)playlistEntity;

#pragma mark - Data Method

- (void)syncDataWithBlock:(void (^)(bool isSuccess))block;

- (void)saveData;
- (void)saveData:(BOOL)isNotify;

#pragma mark - Item

- (void)insertSong:(DropBoxObj *)DropBoxObj;
- (NSFetchRequest *)getSongFilterByName:(NSString *)sName albumId:(NSString *)iAlbumId artistId:(NSString *)iArtistId genreId:(NSString *)iGenreId;
- (NSArray *)getListSongFilterByName:(NSString *)sName albumId:(NSString *)iAlbumId artistId:(NSString *)iArtistId genreId:(NSString *)iGenreId;
- (Item *)getItemBySongId:(NSString *)iSongId;

#pragma mark - File

- (NSFetchRequest *)getFileFilterByName:(NSString *)sName;
- (NSArray *)getListFileFilterByName:(NSString *)sName;

#pragma mark - Album

- (NSArray *)getListAlbumFilterByName:(NSString *)sName albumArtistId:(NSString *)iAlbumArtistId genreId:(NSString *)iGenreId;
- (NSString *)getAlbumIdFromName:(NSString *)sAlbumName year:(int)iYear;
- (BOOL)hasAlbum:(NSString *)iAlbumId;

#pragma mark - AlbumArtist

- (NSArray *)getListAlbumArtistFilterByName:(NSString *)sName;
- (NSString *)getAlbumArtistIdFromName:(NSString *)sAlbumArtistName;
- (BOOL)hasAlbumArtist:(NSString *)iAlbumArtistId;

#pragma mark - Genre

- (NSArray *)getListGenreFilterByName:(NSString *)sName;
- (NSString *)getGenreIdFromName:(NSString *)sGenreName;
- (BOOL)hasGenre:(NSString *)iGenreId;

#pragma mark - Artist

- (NSString *)getArtistIdFromName:(NSString *)sArtistName;

#pragma mark - Delete

- (void)deleteSong:(Item *)item;
- (void)deleteAlbum:(AlbumObj *)album;
- (void)deleteArtist:(AlbumArtistObj *)artist;
- (void)deleteGenre:(GenreObj *)genre;
- (void)deletePlaylist:(Playlist *)playlist;

#pragma mark - Playlist

- (Playlist *)getPlaylistWithType:(kPlaylistType)iPlaylistType andName:(NSString *)sName;
- (Playlist *)createPlaylistWithName:(NSString *)sPlaylistName type:(kPlaylistType)iType;

- (NSFetchRequest *)getListPlaylistIsGetNormalOnly:(BOOL)isNormalOnly;

- (void)addItem:(Item *)item toSpecialList:(kPlaylistType)iPlaylistType;
- (void)removeSongFromPlaylist:(Item *)item;

#pragma mark - Search

- (void)search:(NSString *)sSearch searchType:(kSearchType)iSearchType block:(void (^)(NSArray *results))block;
- (void)cancelSearch;

#pragma mark - DoAction

- (void)doActionWithItem:(id)item withData:(NSArray *)data fromSearch:(BOOL)isSearchActive fromNavigation:(UINavigationController *)navController;
- (void)doUtility:(int)iType withData:(NSArray *)arrData fromNavigation:(UINavigationController *)navController;
- (BOOL)doSwipeActionWithItem:(id)itemObj atIndex:(NSInteger)index isLeftAction:(BOOL)isLeftAction fromNavigation:(UINavigationController *)navController;

#pragma mark - iTunes Sync

- (void)setLastTimeAppSync:(long)lTime;
- (long)getLastTimeAppSync;

@end

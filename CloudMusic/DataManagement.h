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
#import "AlbumObj.h"
#import "AlbumArtistObj.h"
#import "GenresObj.h"
#import "SearchResultObj.h"

#import "SongsCell.h"
#import "AlbumsCell.h"
#import "ArtistsCell.h"
#import "GenresCell.h"
#import "HeaderTitle.h"

@interface DataManagement : NSObject

+ (DataManagement *)sharedInstance;

@property (nonatomic, strong) HCDCoreDataStackController *coreDataController;

- (NSManagedObjectContext *)managedObjectContext;
- (NSEntityDescription *)itemEntity;

#pragma mark - Data Method

- (void)removeAllData;
- (void)syncData;
- (void)saveData;

- (NSFetchRequest *)getListSongFilterByName:(NSString *)sName artistId:(NSNumber *)iArtistId genreId:(NSNumber *)iGenreId;

- (NSArray *)getListSongFilterByName:(NSString *)sName;
- (NSArray *)getListAlbumFilterByName:(NSString *)sName artistId:(NSNumber *)iArtistId genreId:(NSNumber *)iGenreId;
- (NSArray *)getListAlbumArtistFilterByName:(NSString *)sName;
- (NSArray *)getListGenreFilterByName:(NSString *)sName;

#pragma mark - Search

- (void)search:(NSString *)sSearch block:(void (^)(NSArray *results))block;
- (void)cancelSearch;

#pragma mark - iTunes Sync

- (void)setLastTimeAppSync:(long)lTime;
- (long)getLastTimeAppSync;

@end

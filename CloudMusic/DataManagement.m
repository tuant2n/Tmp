//
//  DataManagement.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/19/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "DataManagement.h"
#import <MediaPlayer/MediaPlayer.h>

#import "Utils.h"
#import "GlobalParameter.h"

static DataManagement *_sharedInstance = nil;

@interface DataManagement()

@property (nonatomic, strong) NSOperationQueue *searchQueue;

@end

@implementation DataManagement

#pragma mark - Init

+ (DataManagement *)sharedInstance
{
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[DataManagement alloc] init];
    });
    return _sharedInstance;
}

- (NSOperationQueue *)searchQueue
{
    if (_searchQueue) {
        return _searchQueue;
    }
    
    _searchQueue = [[NSOperationQueue alloc] init];
    _searchQueue.name = @"queue.search";
    _searchQueue.maxConcurrentOperationCount = 1;
    
    return _searchQueue;
}

- (HCDCoreDataStackController *)coreDataController
{
    if (!_coreDataController) {
        HCDCoreDataStack *stack = [HCDCoreDataStack sqliteStackWithName:@"MusicData"];
        _coreDataController = [HCDCoreDataStackController controllerWithStack:stack];
    }
    return _coreDataController;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.coreDataController.stack.mainManagedObjectContext;
}

- (NSEntityDescription *)itemEntity
{
    return [NSEntityDescription entityForName:NSStringFromClass([Item class]) inManagedObjectContext:self.managedObjectContext];
}

- (NSEntityDescription *)fileInfoEntity
{
    return [NSEntityDescription entityForName:NSStringFromClass([FileInfo class]) inManagedObjectContext:self.managedObjectContext];
}

#pragma mark - Data Method

- (void)removeAllData
{
    NSFetchRequest *fetchSongRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Item class])];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"iCloud",@0];
    [fetchSongRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [[self managedObjectContext] executeFetchRequest:fetchSongRequest error:&error];
    
    if (!error) {
        for (Item *item in listData) {
            [[self managedObjectContext] deleteObject:item];
        }
    }
}

- (void)syncData
{
    [self removeAllData];
    
    NSMutableArray *songList = [[NSMutableArray alloc] init];
    MPMediaQuery *allSongsQuery = [MPMediaQuery songsQuery];
    [allSongsQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInteger:MPMediaTypeMusic] forProperty:MPMediaItemPropertyMediaType comparisonType:MPMediaPredicateComparisonContains]];
    for (MPMediaItemCollection *collection in [allSongsQuery collections])
    {
        [songList addObjectsFromArray:[collection items]];
    }
    
    NSManagedObjectContext *backgroundContext = [[DataManagement sharedInstance].coreDataController createChildContextWithType:NSPrivateQueueConcurrencyType];
    [backgroundContext performBlock:^{
        
        for (MPMediaItem *song in songList) {
            Item *item = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Item class]) inManagedObjectContext:backgroundContext];
            [item updateWithMediaItem:song];
        }
        
        [backgroundContext save:nil];
        [self saveData];
    }];
}

- (void)saveData
{
    [self.coreDataController save];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RELOAD_DATA object:nil];
}

- (NSFetchRequest *)getListSongFilterByName:(NSString *)sName albumId:(NSString *)iAlbumId artistId:(NSString *)iArtistId genreId:(NSString *)iGenreId
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[self itemEntity]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sSongNameIndex" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    NSMutableArray *filters = [NSMutableArray new];
    
    if (sName) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sSongNameIndex CONTAINS[cd] %@",sName];
        [filters addObject:predicate];
    }
    if (iAlbumId) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iAlbumId ==[c] %@",iAlbumId];
        [filters addObject:predicate];
    }
    if (iArtistId) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iAlbumArtistId ==[c] %@",iArtistId];
        [filters addObject:predicate];
    }
    if (iGenreId) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iGenreId ==[c] %@",iGenreId];
        [filters addObject:predicate];
    }

    if (filters.count > 0) {
        [request setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:filters]];
    }
    
    return request;
}

- (NSArray *)getListSongFilterByName:(NSString *)sName
{
    NSFetchRequest *request = [self getListSongFilterByName:sName albumId:nil artistId:nil genreId:nil];
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:nil];
    return results;
}

- (NSArray *)getListSongCloudFilterByName:(NSString *)sName
{
    NSPredicate *filterCloudItem = [NSPredicate predicateWithFormat:@"iCloud == %@",@1];
    return [[self getListSongFilterByName:sName] filteredArrayUsingPredicate:filterCloudItem];
}

- (NSArray *)getListAlbumFilterByName:(NSString *)sName albumArtistId:(NSString *)iAlbumArtistId genreId:(NSString *)iGenreId
{
    NSEntityDescription *itemEntity = [self itemEntity];
    
    NSAttributeDescription *iAlbumId = [itemEntity.attributesByName objectForKey:@"iAlbumId"];
    NSAttributeDescription *sAlbumName = [itemEntity.attributesByName objectForKey:@"sAlbumName"];
    NSAttributeDescription *sAlbumArtistName = [itemEntity.attributesByName objectForKey:@"sAlbumArtistName"];
    NSAttributeDescription *iYear = [itemEntity.attributesByName objectForKey:@"iYear"];
    
    NSExpression *listSongId = [NSExpression expressionForKeyPath:@"iSongId"];
    NSExpression *countExpression = [NSExpression expressionForFunction:@"count:" arguments:@[listSongId]];
    NSExpressionDescription *numberOfSong = [[NSExpressionDescription alloc] init];
    [numberOfSong setName: @"numberOfSong"];
    [numberOfSong setExpression:countExpression];
    [numberOfSong setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listDuration = [NSExpression expressionForKeyPath:@"fDuration"];
    NSExpression *sumExpression = [NSExpression expressionForFunction:@"sum:" arguments:@[listDuration]];
    NSExpressionDescription *duration = [[NSExpressionDescription alloc] init];
    [duration setName: @"fDuration"];
    [duration setExpression:sumExpression];
    [duration setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listCloud = [NSExpression expressionForKeyPath:@"iCloud"];
    NSExpression *cloudExpression = [NSExpression expressionForFunction:@"min:" arguments:@[listCloud]];
    NSExpressionDescription *cloud = [[NSExpressionDescription alloc] init];
    [cloud setName: @"iCloud"];
    [cloud setExpression:cloudExpression];
    [cloud setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listArtwork = [NSExpression expressionForKeyPath:@"sArtworkName"];
    NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:@[listArtwork]];
    NSExpressionDescription *artwork = [[NSExpressionDescription alloc] init];
    [artwork setName: @"sArtworkName"];
    [artwork setExpression:maxExpression];
    [artwork setExpressionResultType:NSStringAttributeType];
    
    NSExpression *listArtist = [NSExpression expressionForKeyPath:@"sArtistName"];
    NSExpression *minExpression = [NSExpression expressionForFunction:@"min:" arguments:@[listArtist]];
    NSExpressionDescription *artistName = [[NSExpressionDescription alloc] init];
    [artistName setName: @"sArtistName"];
    [artistName setExpression:minExpression];
    [artistName setExpressionResultType:NSStringAttributeType];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:itemEntity];
    
    NSMutableArray *filters = [NSMutableArray new];
    if (sName) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sAlbumNameIndex CONTAINS[cd] %@",sName];
        [filters addObject:predicate];
    }
    if (iAlbumArtistId) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iAlbumArtistId ==[c] %@",iAlbumArtistId];
        [filters addObject:predicate];
    }
    if (iGenreId) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iGenreId ==[c] %@",iGenreId];
        [filters addObject:predicate];
    }
    if (filters.count > 0) {
        [request setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:filters]];
    }
    
    [request setPropertiesToFetch:@[iAlbumId,sAlbumName,sAlbumArtistName,iYear,cloud,numberOfSong,duration,artwork,artistName]];
    [request setPropertiesToGroupBy:@[iAlbumId,sAlbumName,sAlbumArtistName,iYear]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sAlbumNameIndex" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setResultType:NSDictionaryResultType];
    
    NSMutableArray *albumsArray = [NSMutableArray new];
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:nil];
    
    for (NSDictionary *info in results) {
        AlbumObj *item = [[AlbumObj alloc] initWithInfo:info];
        if (!item) {
            continue;
        }
        [albumsArray addObject:item];
    }
    
    return albumsArray;
}

- (NSArray *)getListAlbumArtistFilterByName:(NSString *)sName
{
    NSEntityDescription *itemEntity = [self itemEntity];
    
    NSAttributeDescription *iAlbumArtistId = [itemEntity.attributesByName objectForKey:@"iAlbumArtistId"];
    NSAttributeDescription *sAlbumArtistName = [itemEntity.attributesByName objectForKey:@"sAlbumArtistName"];
    
    NSExpression *listSongId = [NSExpression expressionForKeyPath:@"iSongId"];
    NSExpression *countSongExpression = [NSExpression expressionForFunction:@"count:" arguments:@[listSongId]];
    NSExpressionDescription *numberOfSong = [[NSExpressionDescription alloc] init];
    [numberOfSong setName: @"numberOfSong"];
    [numberOfSong setExpression:countSongExpression];
    [numberOfSong setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listAlbumId = [NSExpression expressionForKeyPath:@"iAlbumId"];
    NSExpression *distinct = [NSExpression expressionForFunction:@"distinct:" arguments:@[listAlbumId]];
    NSExpression *countAlbumExpression = [NSExpression expressionForFunction:@"count:" arguments:@[distinct]];
    NSExpressionDescription *numberOfAlbum = [[NSExpressionDescription alloc] init];
    [numberOfAlbum setName: @"numberOfAlbum"];
    [numberOfAlbum setExpression:countAlbumExpression];
    [numberOfAlbum setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listDuration = [NSExpression expressionForKeyPath:@"fDuration"];
    NSExpression *sumExpression = [NSExpression expressionForFunction:@"sum:" arguments:@[listDuration]];
    NSExpressionDescription *duration = [[NSExpressionDescription alloc] init];
    [duration setName: @"duration"];
    [duration setExpression:sumExpression];
    [duration setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listCloud = [NSExpression expressionForKeyPath:@"iCloud"];
    NSExpression *cloudExpression = [NSExpression expressionForFunction:@"min:" arguments:@[listCloud]];
    NSExpressionDescription *cloud = [[NSExpressionDescription alloc] init];
    [cloud setName: @"iCloud"];
    [cloud setExpression:cloudExpression];
    [cloud setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listArtwork = [NSExpression expressionForKeyPath:@"sArtworkName"];
    NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:@[listArtwork]];
    NSExpressionDescription *artwork = [[NSExpressionDescription alloc] init];
    [artwork setName: @"sArtworkName"];
    [artwork setExpression:maxExpression];
    [artwork setExpressionResultType:NSStringAttributeType];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:itemEntity];

    if (sName) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sAlbumArtistNameIndex CONTAINS[cd] %@",sName];
        [request setPredicate:predicate];
    }

    [request setPropertiesToFetch:@[iAlbumArtistId,sAlbumArtistName,numberOfSong,numberOfAlbum,duration,cloud,artwork]];
    [request setPropertiesToGroupBy:@[iAlbumArtistId,sAlbumArtistName]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sArtistNameIndex" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setResultType:NSDictionaryResultType];
    
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:nil];

    NSMutableArray *artistArray = [NSMutableArray new];
    for (NSDictionary *info in results) {
        AlbumArtistObj *item = [[AlbumArtistObj alloc] initWithInfo:info];
        if (!item) {
            continue;
        }
        [artistArray addObject:item];
    }
    
    return artistArray;
}

- (NSArray *)getListGenreFilterByName:(NSString *)sName
{
    NSEntityDescription *itemEntity = [[DataManagement sharedInstance] itemEntity];
    
    NSAttributeDescription *iGenreId = [itemEntity.attributesByName objectForKey:@"iGenreId"];
    NSAttributeDescription *sGenreName = [itemEntity.attributesByName objectForKey:@"sGenreName"];
    NSAttributeDescription *sGenreNameIndex = [itemEntity.attributesByName objectForKey:@"sGenreNameIndex"];
    
    NSExpression *listSongId = [NSExpression expressionForKeyPath:@"iSongId"];
    NSExpression *countSongExpression = [NSExpression expressionForFunction:@"count:" arguments:@[listSongId]];
    NSExpressionDescription *numberOfSong = [[NSExpressionDescription alloc] init];
    [numberOfSong setName: @"numberOfSong"];
    [numberOfSong setExpression:countSongExpression];
    [numberOfSong setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listAlbumId = [NSExpression expressionForKeyPath:@"iAlbumId"];
    NSExpression *distinct = [NSExpression expressionForFunction:@"distinct:" arguments:@[listAlbumId]];
    NSExpression *countAlbumExpression = [NSExpression expressionForFunction:@"count:" arguments:@[distinct]];
    NSExpressionDescription *numberOfAlbum = [[NSExpressionDescription alloc] init];
    [numberOfAlbum setName: @"numberOfAlbum"];
    [numberOfAlbum setExpression:countAlbumExpression];
    [numberOfAlbum setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listDuration = [NSExpression expressionForKeyPath:@"fDuration"];
    NSExpression *sumExpression = [NSExpression expressionForFunction:@"sum:" arguments:@[listDuration]];
    NSExpressionDescription *duration = [[NSExpressionDescription alloc] init];
    [duration setName: @"fDuration"];
    [duration setExpression:sumExpression];
    [duration setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listArtwork = [NSExpression expressionForKeyPath:@"sArtworkName"];
    NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:@[listArtwork]];
    NSExpressionDescription *artwork = [[NSExpressionDescription alloc] init];
    [artwork setName: @"sArtworkName"];
    [artwork setExpression:maxExpression];
    [artwork setExpressionResultType:NSStringAttributeType];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:itemEntity];
    
    if (sName) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sGenreNameIndex CONTAINS[cd] %@",sName];
        [request setPredicate:predicate];
    }
    
    [request setPropertiesToFetch:@[iGenreId,sGenreName,sGenreNameIndex,numberOfSong,numberOfAlbum,duration,artwork]];
    [request setPropertiesToGroupBy:@[iGenreId,sGenreName,sGenreNameIndex]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sGenreNameIndex" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setResultType:NSDictionaryResultType];
    
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:nil];
    
    NSMutableArray *genresArray = [NSMutableArray new];
    for (NSDictionary *info in results) {
        GenreObj *item = [[GenreObj alloc] initWithInfo:info];
        if (!item) {
            continue;
        }
        [genresArray addObject:item];
    }
    
    return genresArray;
}

- (NSString *)getAlbumIdFromName:(NSString *)sAlbumName
{
    NSFetchRequest *fetchSongRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Item class])];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K ==[c] %@", @"sAlbumName",sAlbumName];
    [fetchSongRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [[self managedObjectContext] executeFetchRequest:fetchSongRequest error:&error];
    
    if (!error) {
        Item *item = [listData lastObject];
        return item.iAlbumId;
    }
    return nil;
}

- (NSString *)getAlbumArtistIdFromName:(NSString *)sAlbumArtistName
{
    NSFetchRequest *fetchSongRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Item class])];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K ==[c] %@", @"sAlbumArtistName",sAlbumArtistName];
    [fetchSongRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [[self managedObjectContext] executeFetchRequest:fetchSongRequest error:&error];
    
    if (!error) {
        Item *item = [listData lastObject];
        return item.iAlbumArtistId;
    }
    return nil;
}

- (NSString *)getArtistIdFromName:(NSString *)sArtistName
{
    NSFetchRequest *fetchSongRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Item class])];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K ==[c] %@", @"sArtistName",sArtistName];
    [fetchSongRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [[self managedObjectContext] executeFetchRequest:fetchSongRequest error:&error];
    
    if (!error) {
        Item *item = [listData lastObject];
        return item.iArtistId;
    }
    return nil;
}

- (NSString *)getGenreIdFromName:(NSString *)sGenreName
{
    NSFetchRequest *fetchSongRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Item class])];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K ==[c] %@", @"sGenreName",sGenreName];
    [fetchSongRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [[self managedObjectContext] executeFetchRequest:fetchSongRequest error:&error];
    
    if (!error) {
        Item *item = [listData lastObject];
        return item.iGenreId;
    }
    return nil;
}

- (void)deleteSong:(Item *)item
{
    [[self managedObjectContext] deleteObject:item];
    [self saveData];
}

- (void)deleteAlbum:(AlbumObj *)album
{
    NSFetchRequest *request = [[DataManagement sharedInstance] getListSongFilterByName:nil albumId:album.iAlbumId artistId:nil genreId:nil];
    NSArray *listSongs = [[[DataManagement sharedInstance] managedObjectContext] executeFetchRequest:request error:nil];
    
    for (Item *song in listSongs) {
        [[self managedObjectContext] deleteObject:song];
    }
    
    [self saveData];
}

#pragma mark - Search

- (void)search:(NSString *)sSearch searchType:(kSearchType)iSearchType block:(void (^)(NSArray *results))block
{
    [self cancelSearch];

    SearchOperation *operation = [[SearchOperation alloc] initWitSearchString:sSearch searchType:iSearchType];
    __weak SearchOperation *blockOperation = operation;
    
    [operation setCompletionBlock:^{
        if (!blockOperation.isCancelled) {
            if (block) {
                block(blockOperation.resultArray);
            }
        }
        else {
            NSLog(@"CANCEL");
        }
    }];
    [self.searchQueue addOperation:operation];
}

- (void)cancelSearch
{
    if ([self.searchQueue operationCount] > 0) {
        [self.searchQueue cancelAllOperations];
    }
}

#pragma mark - DoAction

- (void)doActionWithItem:(id)item fromNavigation:(UINavigationController *)navController
{
    if ([item isKindOfClass:[Item class]]) {
        [[GlobalParameter sharedInstance] setCurrentItemPlay:(Item *)item];
    }
    else if ([item isKindOfClass:[AlbumObj class]]) {
        AlbumListViewController *vc = [[AlbumListViewController alloc] init];
        vc.currentAlbum = (AlbumObj *)item;
        [navController pushViewController:vc animated:YES];
    }
    else if ([item isKindOfClass:[AlbumArtistObj class]]) {
        AlbumArtistObj *artist = (AlbumArtistObj *)item;
        
        AlbumsViewController *vc = [[AlbumsViewController alloc] init];
        vc.sTitle = artist.sAlbumArtistName;
        vc.iAlbumArtistId = artist.iAlbumArtistId;
        [navController pushViewController:vc animated:YES];
    }
    else if ([item isKindOfClass:[GenreObj class]]) {
        GenreObj *genre = (GenreObj *)item;
        
        AlbumsViewController *vc = [[AlbumsViewController alloc] init];
        vc.sTitle = genre.sGenreName;
        vc.iGenreId = genre.iGenreId;
        [navController pushViewController:vc animated:YES];
    }
}

#pragma mark - iTunes Sync

- (void)setLastTimeAppSync:(long)lTime
{
    [[NSUserDefaults standardUserDefaults] setInteger:lTime forKey:@"LASTTIME_APP_SYNC"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (long)getLastTimeAppSync
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"LASTTIME_APP_SYNC"];
}

@end

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

#import "MPMediaItem+Accessors.h"

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

- (NSEntityDescription *)fileEntity
{
    return [NSEntityDescription entityForName:NSStringFromClass([File class]) inManagedObjectContext:self.managedObjectContext];
}

- (NSEntityDescription *)playlistEntity
{
    return [NSEntityDescription entityForName:NSStringFromClass([Playlist class]) inManagedObjectContext:self.managedObjectContext];
}

#pragma mark - Data Method

- (void)syncDataWithBlock:(void (^)(bool isSuccess))block
{
    NSOperationQueue *syncDataQueue = [[NSOperationQueue alloc] init];
    syncDataQueue.name = @"queue.sync.data";
    
    [syncDataQueue addOperationWithBlock:^{
        NSMutableArray *songList = [[NSMutableArray alloc] init];
        MPMediaQuery *allSongsQuery = [MPMediaQuery songsQuery];
        [allSongsQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInteger:MPMediaTypeMusic] forProperty:MPMediaItemPropertyMediaType comparisonType:MPMediaPredicateComparisonContains]];
        for (MPMediaItemCollection *collection in [allSongsQuery collections])
        {
            [songList addObjectsFromArray:[collection items]];
        }
        NSMutableArray *listSongId = [[NSMutableArray alloc] init];
        for (MPMediaItem *song in songList)
        {
            [listSongId addObject:[song.itemPersistentID stringValue]];
        }
        NSString *sListSongId = [[listSongId valueForKey:@"description"] componentsJoinedByString:@","];
        
        NSFetchRequest *fetchSongRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Item class])];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"iCloudItem",@0];
        [fetchSongRequest setPredicate:predicate];
        NSArray *listSong = [[self managedObjectContext] executeFetchRequest:fetchSongRequest error:nil];
        for (Item *item in listSong) {
            if ([sListSongId rangeOfString:item.iSongId].location == NSNotFound) {
                [self deleteSong:item];
            }
        }
        
        for (MPMediaItem *song in songList)
        {
            NSString *iSongId = [song.itemPersistentID stringValue];
            
            Item *item = [self getItemBySongId:iSongId];
            if (!item) {
                item = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Item class]) inManagedObjectContext:self.managedObjectContext];
            }
            [item updateWithMediaItem:song];
        }
        
        [self createDefaultPlaylist];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self saveData];
            [self setLastTimeAppSync:[[[MPMediaLibrary defaultMediaLibrary] lastModifiedDate] timeIntervalSince1970]];
            
            if (block) {
                block(YES);
            }
        });
    }];
}

- (void)saveData
{
    [self saveData:YES];
}

- (void)saveData:(BOOL)isNotify
{
    [self.coreDataController save];
    
    if (isNotify) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RELOAD_DATA object:nil];
    }
}

#pragma mark - Item

- (void)insertSong:(DropBoxObj *)dropboxItem
{
    NSDictionary *songInfo = [[NSDictionary alloc] initWithDictionary:dropboxItem.songInfo];
    NSURL *songUrl = [NSURL fileURLWithPath:dropboxItem.sExportPath];
    
    Item *item = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Item class]) inManagedObjectContext:self.managedObjectContext];
    [item updateWithSongUrl:songUrl songInfo:songInfo];
    
    File *fileInfo = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([File class]) inManagedObjectContext:self.managedObjectContext];
    fileInfo.sFileName = [songUrl.path lastPathComponent];
    fileInfo.lTimestamp = @(time(nil));
    fileInfo.sSize = [Utils getFileSize:songUrl.path];
    item.fileInfo = fileInfo;
    
    [self addItem:item toSpecialList:kPlaylistTypeRecentlyAdded];
}

- (NSFetchRequest *)getSongFilterByName:(NSString *)sName albumId:(NSString *)iAlbumId artistId:(NSString *)iArtistId genreId:(NSString *)iGenreId
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

- (NSArray *)getListSongFilterByName:(NSString *)sName albumId:(NSString *)iAlbumId artistId:(NSString *)iArtistId genreId:(NSString *)iGenreId
{
    NSFetchRequest *request = [self getSongFilterByName:sName albumId:iAlbumId artistId:iArtistId genreId:iGenreId];
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:nil];
    return results;
}

- (Item *)getItemBySongId:(NSString *)iSongId
{
    NSFetchRequest *fetchSongRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Item class])];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K ==[c] %@", @"iSongId",iSongId];
    [fetchSongRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [[self managedObjectContext] executeFetchRequest:fetchSongRequest error:&error];
    
    if (!error) {
        return [listData lastObject];
    }
    return nil;
}

#pragma mark - File

- (NSFetchRequest *)getFileFilterByName:(NSString *)sName
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[self fileEntity]];
    
    NSSortDescriptor *sortByType = [[NSSortDescriptor alloc] initWithKey:@"lTimestamp" ascending:YES];
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"sFileName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    [request setSortDescriptors:@[sortByType,sortByName]];
    
    NSMutableArray *filters = [NSMutableArray new];
    
    if (sName) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sFileName CONTAINS[cd] %@",sName];
        [filters addObject:predicate];
    }

    if (filters.count > 0) {
        [request setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:filters]];
    }
    
    return request;
}

- (NSArray *)getListFileFilterByName:(NSString *)sName
{
    NSFetchRequest *request = [self getFileFilterByName:sName];
    NSArray *results = [[self managedObjectContext] executeFetchRequest:request error:nil];
    return results;
}

#pragma mark - Album

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
    [numberOfSong setName:@"numberOfSong"];
    [numberOfSong setExpression:countExpression];
    [numberOfSong setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listDuration = [NSExpression expressionForKeyPath:@"fDuration"];
    NSExpression *sumExpression = [NSExpression expressionForFunction:@"sum:" arguments:@[listDuration]];
    NSExpressionDescription *duration = [[NSExpressionDescription alloc] init];
    [duration setName:@"fDuration"];
    [duration setExpression:sumExpression];
    [duration setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listCloud = [NSExpression expressionForKeyPath:@"iCloudItem"];
    NSExpression *cloudExpression = [NSExpression expressionForFunction:@"min:" arguments:@[listCloud]];
    NSExpressionDescription *cloud = [[NSExpressionDescription alloc] init];
    [cloud setName:@"iCloud"];
    [cloud setExpression:cloudExpression];
    [cloud setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listArtwork = [NSExpression expressionForKeyPath:@"sArtworkName"];
    NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:@[listArtwork]];
    NSExpressionDescription *artwork = [[NSExpressionDescription alloc] init];
    [artwork setName:@"sArtworkName"];
    [artwork setExpression:maxExpression];
    [artwork setExpressionResultType:NSStringAttributeType];
    
    NSExpression *listArtist = [NSExpression expressionForKeyPath:@"sArtistName"];
    NSExpression *minExpression = [NSExpression expressionForFunction:@"min:" arguments:@[listArtist]];
    NSExpressionDescription *artistName = [[NSExpressionDescription alloc] init];
    [artistName setName:@"sArtistName"];
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

- (NSString *)getAlbumIdFromName:(NSString *)sAlbumName year:(int)iYear
{
    NSFetchRequest *fetchSongRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Item class])];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sAlbumName ==[c] %@ AND iYear == %d",sAlbumName,iYear];
    [fetchSongRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [[self managedObjectContext] executeFetchRequest:fetchSongRequest error:&error];
    
    if (!error) {
        Item *item = [listData lastObject];
        return item.iAlbumId;
    }
    return nil;
}

- (BOOL)hasAlbum:(NSString *)iAlbumId
{
    NSFetchRequest *fetchSongRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Item class])];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iAlbumId ==[c] %@",iAlbumId];
    [fetchSongRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [[self managedObjectContext] executeFetchRequest:fetchSongRequest error:&error];
    
    if (!error) {
        return (listData.count > 0);
    }
    return NO;
}

#pragma mark - AlbumArtist

- (NSArray *)getListAlbumArtistFilterByName:(NSString *)sName
{
    NSEntityDescription *itemEntity = [self itemEntity];
    
    NSAttributeDescription *iAlbumArtistId = [itemEntity.attributesByName objectForKey:@"iAlbumArtistId"];
    NSAttributeDescription *sAlbumArtistName = [itemEntity.attributesByName objectForKey:@"sAlbumArtistName"];
    
    NSExpression *listSongId = [NSExpression expressionForKeyPath:@"iSongId"];
    NSExpression *countSongExpression = [NSExpression expressionForFunction:@"count:" arguments:@[listSongId]];
    NSExpressionDescription *numberOfSong = [[NSExpressionDescription alloc] init];
    [numberOfSong setName:@"numberOfSong"];
    [numberOfSong setExpression:countSongExpression];
    [numberOfSong setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listAlbumId = [NSExpression expressionForKeyPath:@"iAlbumId"];
    NSExpression *distinct = [NSExpression expressionForFunction:@"distinct:" arguments:@[listAlbumId]];
    NSExpression *countAlbumExpression = [NSExpression expressionForFunction:@"count:" arguments:@[distinct]];
    NSExpressionDescription *numberOfAlbum = [[NSExpressionDescription alloc] init];
    [numberOfAlbum setName:@"numberOfAlbum"];
    [numberOfAlbum setExpression:countAlbumExpression];
    [numberOfAlbum setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listDuration = [NSExpression expressionForKeyPath:@"fDuration"];
    NSExpression *sumExpression = [NSExpression expressionForFunction:@"sum:" arguments:@[listDuration]];
    NSExpressionDescription *duration = [[NSExpressionDescription alloc] init];
    [duration setName:@"duration"];
    [duration setExpression:sumExpression];
    [duration setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listCloud = [NSExpression expressionForKeyPath:@"iCloudItem"];
    NSExpression *cloudExpression = [NSExpression expressionForFunction:@"min:" arguments:@[listCloud]];
    NSExpressionDescription *cloud = [[NSExpressionDescription alloc] init];
    [cloud setName:@"iCloud"];
    [cloud setExpression:cloudExpression];
    [cloud setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listArtwork = [NSExpression expressionForKeyPath:@"sArtworkName"];
    NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:@[listArtwork]];
    NSExpressionDescription *artwork = [[NSExpressionDescription alloc] init];
    [artwork setName:@"sArtworkName"];
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

- (BOOL)hasAlbumArtist:(NSString *)iAlbumArtistId
{
    NSFetchRequest *fetchSongRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Item class])];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iAlbumArtistId ==[c] %@",iAlbumArtistId];
    [fetchSongRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [[self managedObjectContext] executeFetchRequest:fetchSongRequest error:&error];
    
    if (!error) {
        return (listData.count > 0);
    }
    return NO;
}

#pragma mark - Genre

- (NSArray *)getListGenreFilterByName:(NSString *)sName
{
    NSEntityDescription *itemEntity = [self itemEntity];
    
    NSAttributeDescription *iGenreId = [itemEntity.attributesByName objectForKey:@"iGenreId"];
    NSAttributeDescription *sGenreName = [itemEntity.attributesByName objectForKey:@"sGenreName"];
    NSAttributeDescription *sGenreNameIndex = [itemEntity.attributesByName objectForKey:@"sGenreNameIndex"];
    
    NSExpression *listSongId = [NSExpression expressionForKeyPath:@"iSongId"];
    NSExpression *countSongExpression = [NSExpression expressionForFunction:@"count:" arguments:@[listSongId]];
    NSExpressionDescription *numberOfSong = [[NSExpressionDescription alloc] init];
    [numberOfSong setName:@"numberOfSong"];
    [numberOfSong setExpression:countSongExpression];
    [numberOfSong setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listAlbumId = [NSExpression expressionForKeyPath:@"iAlbumId"];
    NSExpression *distinct = [NSExpression expressionForFunction:@"distinct:" arguments:@[listAlbumId]];
    NSExpression *countAlbumExpression = [NSExpression expressionForFunction:@"count:" arguments:@[distinct]];
    NSExpressionDescription *numberOfAlbum = [[NSExpressionDescription alloc] init];
    [numberOfAlbum setName:@"numberOfAlbum"];
    [numberOfAlbum setExpression:countAlbumExpression];
    [numberOfAlbum setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listDuration = [NSExpression expressionForKeyPath:@"fDuration"];
    NSExpression *sumExpression = [NSExpression expressionForFunction:@"sum:" arguments:@[listDuration]];
    NSExpressionDescription *duration = [[NSExpressionDescription alloc] init];
    [duration setName:@"fDuration"];
    [duration setExpression:sumExpression];
    [duration setExpressionResultType:NSInteger32AttributeType];
    
    NSExpression *listArtwork = [NSExpression expressionForKeyPath:@"sArtworkName"];
    NSExpression *maxExpression = [NSExpression expressionForFunction:@"max:" arguments:@[listArtwork]];
    NSExpressionDescription *artwork = [[NSExpressionDescription alloc] init];
    [artwork setName:@"sArtworkName"];
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

- (BOOL)hasGenre:(NSString *)iGenreId
{
    NSFetchRequest *fetchSongRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Item class])];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iGenreId ==[c] %@",iGenreId];
    [fetchSongRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [[self managedObjectContext] executeFetchRequest:fetchSongRequest error:&error];
    
    if (!error) {
        return (listData.count > 0);
    }
    return NO;
}

#pragma mark - Artist

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

#pragma mark - Delete

- (void)deleteSongs:(NSArray *)listSongs
{
    for (Item *item in listSongs) {
        [[self managedObjectContext] deleteObject:item];
    }
    
    [self saveData];
}

- (void)deleteSong:(Item *)song
{
    NSString *sSongPath = [[Utils dropboxPath] stringByAppendingPathComponent:song.fileInfo.sFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:sSongPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:sSongPath error:nil];
    }
    
    if (song.fileInfo) {
        [[self managedObjectContext] deleteObject:song.fileInfo];
    }
    [self removeSongFromPlaylist:song];
    [[self managedObjectContext] deleteObject:song];
    
    [self saveData];
}

- (void)deleteAlbum:(AlbumObj *)album
{
    NSFetchRequest *request = [self getSongFilterByName:nil albumId:album.iAlbumId artistId:nil genreId:nil];
    NSArray *listSongs = [[self managedObjectContext] executeFetchRequest:request error:nil];
    [self deleteSongs:listSongs];
}

- (void)deleteArtist:(AlbumArtistObj *)artist
{
    NSFetchRequest *request = [self getSongFilterByName:nil albumId:nil artistId:artist.iAlbumArtistId genreId:nil];
    NSArray *listSongs = [[self managedObjectContext] executeFetchRequest:request error:nil];
    [self deleteSongs:listSongs];
}

- (void)deleteGenre:(GenreObj *)genre
{
    NSFetchRequest *request = [self getSongFilterByName:nil albumId:nil artistId:nil genreId:genre.iGenreId];
    NSArray *listSongs = [[self managedObjectContext] executeFetchRequest:request error:nil];
    [self deleteSongs:listSongs];
}

- (void)deletePlaylist:(Playlist *)playlist
{
    [[self managedObjectContext] deleteObject:playlist];
    [self saveData:NO];
}

#pragma mark - Playlist

- (void)createDefaultPlaylist
{
    if (![self getPlaylistWithType:kPlaylistTypeMyTopRated andName:nil]) {
        [self createPlaylistWithName:@"My Top Rated" type:kPlaylistTypeMyTopRated];
    }
    
    if (![self getPlaylistWithType:kPlaylistTypeRecentlyAdded andName:nil]) {
        [self createPlaylistWithName:@"Recently Added" type:kPlaylistTypeRecentlyAdded];
    }
    
    if (![self getPlaylistWithType:kPlaylistTypeRecentlyPlayed andName:nil]) {
        [self createPlaylistWithName:@"Recently Played" type:kPlaylistTypeRecentlyPlayed];
    }
    
    if (![self getPlaylistWithType:kPlaylistTypeTopMostPlayed andName:nil]) {
        [self createPlaylistWithName:@"Top 25 Most Played" type:kPlaylistTypeTopMostPlayed];
    }
}

- (Playlist *)createPlaylistWithName:(NSString *)sPlaylistName type:(kPlaylistType)iType
{
    Playlist *playlist = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Playlist class]) inManagedObjectContext:self.managedObjectContext];
    playlist.iPlaylistId = [NSString stringWithFormat:@"%@-%d",[Utils getTimestamp],iType];
    playlist.iPlaylistType = @(iType);
    playlist.sPlaylistName = sPlaylistName;
    playlist.isSmartPlaylist = @(iType != kPlaylistTypeNormal);
    
    return playlist;
}

- (Playlist *)getPlaylistWithType:(kPlaylistType)iPlaylistType andName:(NSString *)sName
{
    NSFetchRequest *fetchSongRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Playlist class])];
    
    NSMutableArray *predicates = [NSMutableArray new];
    [predicates addObject:[NSPredicate predicateWithFormat:@"iPlaylistType == %d",iPlaylistType]];
    if (sName) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"sPlaylistName ==[c] %@",sName]];
    }
    [fetchSongRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
    
    NSError *error = nil;
    NSArray *listData = [[self managedObjectContext] executeFetchRequest:fetchSongRequest error:&error];
    
    if (!error) {
        return [listData lastObject];
    }
    return nil;
}

- (NSFetchRequest *)getListPlaylistIsGetNormalOnly:(BOOL)isNormalOnly
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[self playlistEntity]];
    
    NSSortDescriptor *sortByType = [[NSSortDescriptor alloc] initWithKey:@"iPlaylistType" ascending:NO];
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"sPlaylistName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor *sortForView = [[NSSortDescriptor alloc] initWithKey:@"isSmartPlaylist" ascending:NO];
    
    [request setSortDescriptors:@[sortByType,sortByName,sortForView]];
    
    if (isNormalOnly) {
        [request setPredicate:[NSPredicate predicateWithFormat:@"isSmartPlaylist == NO"]];
    }
    
    return request;
}

- (void)addItem:(Item *)newSong toSpecialList:(kPlaylistType)iPlaylistType
{
    Playlist *playlist = [self getPlaylistWithType:iPlaylistType andName:nil];
    if (!playlist)
    {
        playlist = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Playlist class]) inManagedObjectContext:self.managedObjectContext];
        playlist.iPlaylistId = [NSString stringWithFormat:@"%@-%d",[Utils getTimestamp],iPlaylistType];
        playlist.iPlaylistType = @(iPlaylistType);
        
        if (iPlaylistType == kPlaylistTypeMyTopRated) {
            playlist.sPlaylistName = @"My Top Rated";
        }
        else if (iPlaylistType == kPlaylistTypeRecentlyAdded) {
            playlist.sPlaylistName = @"Recently Added";
        }
        else if (iPlaylistType == kPlaylistTypeRecentlyPlayed) {
            playlist.sPlaylistName = @"Recently Played";
        }
        else if (iPlaylistType == kPlaylistTypeTopMostPlayed) {
            playlist.sPlaylistName = @"Top 25 Most Played";
        }
        
        playlist.isSmartPlaylist = @YES;
    }
    
    NSMutableArray *listSong = [[NSMutableArray alloc] initWithArray:[playlist getPlaylist]];
    int fDuration = 0;
    
    if (iPlaylistType == kPlaylistTypeMyTopRated) {
        
    }
    else if (iPlaylistType == kPlaylistTypeRecentlyAdded) {
        [listSong insertObject:newSong.iSongId atIndex:0];
        fDuration = [playlist.fDuration intValue] + [newSong.fDuration intValue];
    }
    else if (iPlaylistType == kPlaylistTypeRecentlyPlayed) {
        if ([listSong containsObject:newSong.iSongId]) {
            [listSong removeObject:newSong.iSongId];
            [listSong insertObject:newSong.iSongId atIndex:0];
        }
        else {
            [listSong insertObject:newSong.iSongId atIndex:0];
            fDuration += [newSong.fDuration intValue];
        }
    }
    else if (iPlaylistType == kPlaylistTypeTopMostPlayed) {
        if ([listSong containsObject:newSong.iSongId]) {
            [listSong removeObject:newSong.iSongId];
            [listSong insertObject:newSong.iSongId atIndex:0];
        }
        else {
            if (listSong.count == 25) {
                NSString *sLastSongId = [listSong lastObject];
                Item *song = [self getItemBySongId:sLastSongId];
                if (song) {
                    fDuration -= [song.fDuration intValue];
                }
                [listSong removeObject:sLastSongId];
            }
            [listSong insertObject:newSong.iSongId atIndex:0];
            fDuration += [newSong.fDuration intValue];
        }
    }
    
    if (newSong.sArtworkName) {
        [playlist setArtwork:newSong.sArtworkName];
    }
    
    if (fDuration > 0) {
        playlist.fDuration = @(fDuration);
    }

    [playlist setPlaylist:listSong];
    
    [self saveData:NO];
}

- (void)removeSongFromPlaylist:(Item *)item
{
    NSFetchRequest *getPlaylist = [self getListPlaylistIsGetNormalOnly:NO];
    
    NSError *error = nil;
    NSArray *playlists = [[self managedObjectContext] executeFetchRequest:getPlaylist error:&error];
    for (Playlist *playlist in playlists)
    {
        int fDuration = [playlist.fDuration intValue];
        
        NSMutableArray *listSong = [[NSMutableArray alloc] initWithArray:[playlist getPlaylist]];
        for (NSString *sSongId in listSong)
        {
            if ([sSongId isEqualToString:item.iSongId]) {
                fDuration -= [item.fDuration intValue];
            }
        }
        
        if (fDuration < 0) {
            fDuration = 0;
        }
        playlist.fDuration = @(fDuration);
        
        [listSong removeObject:item.iSongId];
        [playlist setPlaylist:[listSong copy]];
        
        if (listSong.count <= 0) {
            [playlist setArtwork:nil];
        }
    }
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
            TTLog(@"CANCEL");
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

- (void)doActionWithItem:(id)item withData:(NSArray *)data fromSearch:(BOOL)isSearchActive fromNavigation:(UINavigationController *)navController
{
    if ([item isKindOfClass:[Item class]])
    {
        if (isSearchActive) {
            [[GlobalParameter sharedInstance] setCurrentPlaying:item];
        }
        else {
            if (data) {
                // Play All Song In List Start With 'item'
            }
        }
    }
    if ([item isKindOfClass:[File class]]) {
        if (isSearchActive) {
            File *file = (File *)item;
            [[GlobalParameter sharedInstance] setCurrentPlaying:file.item];
        }
        else {
            // Play All Song Downloaded With 'item'
        }
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
    else if ([item isKindOfClass:[Playlist class]]) {
        Playlist *playlist = (Playlist *)item;
        
        if (playlist.isSmartPlaylist.boolValue) {
            if ([playlist getPlaylist].count <= 0) {
                return;
            }
        }
        
        PlaylistsListSongViewController *vc = [[PlaylistsListSongViewController alloc] init];
        vc.currentPlaylist = playlist;
        vc.hidesBottomBarWhenPushed = YES;
        [navController pushViewController:vc animated:YES];
    }
}

- (void)doUtility:(int)iType withData:(NSArray *)arrData fromNavigation:(UINavigationController *)navController
{
    if (iType == kHeaderUtilTypeShuffle) {
        if (arrData) {
            // Play Shuffle A List
        }
        else {
            // Play Shuffle All Song
        }
    }
    else if (iType == kHeaderUtilTypeShuffleFromSong) {
        // Play Shuffle All Song
    }
    else if (iType == kHeaderUtilTypeGoAllAlbums) {
        AlbumsViewController *vc = [[AlbumsViewController alloc] init];
        [navController pushViewController:vc animated:YES];
    }
    else if (iType == kHeaderUtilTypeGoAllSongs) {
        SongsViewController *vc = [[SongsViewController alloc] init];
        [navController pushViewController:vc animated:YES];
    }
    else if (iType == kHeaderUtilTypeCreatePlaylistWithData) {
        MakePlaylistViewController *vc = [[MakePlaylistViewController alloc] init];
        vc.arrListItem = arrData;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [navController presentViewController:nav animated:YES completion:nil];
    }
    else if (iType == kHeaderUtilTypeCreateNewPlaylist) {
        MakePlaylistViewController *vc = [[MakePlaylistViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [navController presentViewController:nav animated:YES completion:nil];
    }
}

- (BOOL)doSwipeActionWithItem:(id)itemObj atIndex:(NSInteger)index isLeftAction:(BOOL)isLeftAction fromNavigation:(UINavigationController *)navController
{
    if ([itemObj isKindOfClass:[Item class]] || [itemObj isKindOfClass:[File class]])
    {
        Item *item = nil;
        
        if ([itemObj isKindOfClass:[Item class]]) {
            item = (Item *)itemObj;
        }
        else if ([itemObj isKindOfClass:[File class]]) {
            File *file = (File *)itemObj;
            item = file.item;
        }
        
        if (!item) {
            return YES;
        }
        
        if (isLeftAction)
        {
            if (index == 0) {
                CreatePlaylistViewController *vc = [[CreatePlaylistViewController alloc] init];
                vc.item = item;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [navController presentViewController:nav animated:YES completion:nil];
            }
            else if ( index == 1 && item.isCloud) {
                EditViewController *vc = [[EditViewController alloc] init];
                vc.song = item;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [navController presentViewController:nav animated:YES completion:nil];
            }
        }
        else {
            if (index == 0 && item.isCloud) {
                [self deleteSong:item];
                return NO;
            }
        }
    }
    else if ([itemObj isKindOfClass:[AlbumObj class]])
    {
        AlbumObj *album = (AlbumObj *)itemObj;
        
        if (isLeftAction)
        {
            if (index == 0) {
                CreatePlaylistViewController *vc = [[CreatePlaylistViewController alloc] init];
                vc.item = album;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [navController presentViewController:nav animated:YES completion:nil];
            }
            else if (index == 1 && album.isCloud) {
                EditViewController *vc = [[EditViewController alloc] init];
                vc.album = album;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [navController presentViewController:nav animated:YES completion:nil];
            }
        }
        else {
            if (index == 0 && album.isCloud) {
                [self deleteAlbum:album];
                return NO;
            }
        }
    }
    else if ([itemObj isKindOfClass:[AlbumArtistObj class]])
    {
        AlbumArtistObj *artist = (AlbumArtistObj *)itemObj;
        
        if (isLeftAction)
        {
            if (index == 0) {
                CreatePlaylistViewController *vc = [[CreatePlaylistViewController alloc] init];
                vc.item = artist;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [navController presentViewController:nav animated:YES completion:nil];
            }
        }
        else {
            if (index == 0) {
                [self deleteArtist:artist];
                return NO;
            }
        }
    }
    else if ([itemObj isKindOfClass:[GenreObj class]])
    {
        GenreObj *genre = (GenreObj *)itemObj;
        
        if (isLeftAction)
        {
            if (index == 0) {
                CreatePlaylistViewController *vc = [[CreatePlaylistViewController alloc] init];
                vc.item = genre;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [navController presentViewController:nav animated:YES completion:nil];
            }
        }
        else {
            if (index == 0) {
                [self deleteGenre:genre];
                return NO;
            }
        }
    }
    else if ([itemObj isKindOfClass:[Playlist class]])
    {
        Playlist *playlist = (Playlist *)itemObj;
        if (index == 0 && !isLeftAction) {
            [self deletePlaylist:playlist];
            return NO;
        }
    }
    
    return YES;
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

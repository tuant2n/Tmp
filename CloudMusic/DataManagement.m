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

- (NSEntityDescription *)fileInfoEntity
{
    return [NSEntityDescription entityForName:NSStringFromClass([FileInfo class]) inManagedObjectContext:self.managedObjectContext];
}

- (NSEntityDescription *)playlistEntity
{
    return [NSEntityDescription entityForName:NSStringFromClass([Playlist class]) inManagedObjectContext:self.managedObjectContext];
}

#pragma mark - Data Method

- (void)syncDataWithBlock:(void (^)(bool isSuccess))block
{
    NSOperationQueue *addGifQueu = [[NSOperationQueue alloc] init];
    addGifQueu.name = @"queue.sync.data";
    
    [addGifQueu addOperationWithBlock:^{
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
                [self removeItemFromPlaylist:item];
                [self.managedObjectContext deleteObject:item];
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

- (void)insertSong:(DropBoxObj *)dropboxItem
{
    NSDictionary *songInfo = [[NSDictionary alloc] initWithDictionary:dropboxItem.songInfo];
    NSURL *songUrl = [NSURL fileURLWithPath:dropboxItem.sExportPath];
    
    Item *item = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Item class]) inManagedObjectContext:self.managedObjectContext];
    [item updateWithSongUrl:songUrl songInfo:songInfo];
    
    FileInfo *fileInfo = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([FileInfo class]) inManagedObjectContext:self.managedObjectContext];
    fileInfo.sFileName = [songUrl.path lastPathComponent];
    fileInfo.lTimestamp = @(time(nil));
    fileInfo.sSize = [Utils getFileSize:songUrl.path];
    item.fileInfo = fileInfo;
    
    [self addItem:item toSpecialList:kPlaylistTypeRecentlyAdded];
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
    NSPredicate *filterCloudItem = [NSPredicate predicateWithFormat:@"iCloudItem == %@",@1];
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
    NSFetchRequest *request = [self getListSongFilterByName:nil albumId:album.iAlbumId artistId:nil genreId:nil];
    NSArray *listSongs = [[self managedObjectContext] executeFetchRequest:request error:nil];
    
    for (Item *song in listSongs) {
        [[self managedObjectContext] deleteObject:song];
    }
    
    [self saveData];
}

- (void)deleteArtist:(AlbumArtistObj *)artist
{
    NSFetchRequest *request = [self getListSongFilterByName:nil albumId:nil artistId:artist.iAlbumArtistId genreId:nil];
    NSArray *listSongs = [[self managedObjectContext] executeFetchRequest:request error:nil];
    
    for (Item *song in listSongs) {
        [[self managedObjectContext] deleteObject:song];
    }
    
    [self saveData];
}

- (void)deleteGenre:(GenreObj *)genre
{
    NSFetchRequest *request = [self getListSongFilterByName:nil albumId:nil artistId:nil genreId:genre.iGenreId];
    NSArray *listSongs = [[self managedObjectContext] executeFetchRequest:request error:nil];
    
    for (Item *song in listSongs) {
        [[self managedObjectContext] deleteObject:song];
    }
    
    [self saveData];
}

#pragma mark - Playlist

- (void)createDefaultPlaylist
{
    if (![self getPlaylistWithType:kPlaylistTypeMyTopRated andName:nil]) {
        Playlist *playlistMyTopRated = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Playlist class]) inManagedObjectContext:self.managedObjectContext];
        playlistMyTopRated.iPlaylistId = [NSString stringWithFormat:@"%@ - %d",[Utils getTimestamp],kPlaylistTypeMyTopRated];
        playlistMyTopRated.iPlaylistType = @(kPlaylistTypeMyTopRated);
        playlistMyTopRated.sPlaylistName = @"My Top Rated";
        playlistMyTopRated.isSmartPlaylist = @YES;
    }
    
    if (![self getPlaylistWithType:kPlaylistTypeRecentlyAdded andName:nil]) {
        Playlist *playlistRecentlyAdded = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Playlist class]) inManagedObjectContext:self.managedObjectContext];
        playlistRecentlyAdded.iPlaylistId = [NSString stringWithFormat:@"%@ - %d",[Utils getTimestamp],kPlaylistTypeRecentlyAdded];
        playlistRecentlyAdded.iPlaylistType = @(kPlaylistTypeRecentlyAdded);
        playlistRecentlyAdded.sPlaylistName = @"Recently Added";
        playlistRecentlyAdded.isSmartPlaylist = @YES;
    }
    
    if (![self getPlaylistWithType:kPlaylistTypeRecentlyPlayed andName:nil]) {
        Playlist *playlistRecentlyPlayed = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Playlist class]) inManagedObjectContext:self.managedObjectContext];
        playlistRecentlyPlayed.iPlaylistId = [NSString stringWithFormat:@"%@ - %d",[Utils getTimestamp],kPlaylistTypeRecentlyPlayed];
        playlistRecentlyPlayed.iPlaylistType = @(kPlaylistTypeRecentlyPlayed);
        playlistRecentlyPlayed.sPlaylistName = @"Recently Played";
        playlistRecentlyPlayed.isSmartPlaylist = @YES;
    }
    
    if (![self getPlaylistWithType:kPlaylistTypeTopMostPlayed andName:nil]) {
        Playlist *playlistTopMostPlayed = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Playlist class]) inManagedObjectContext:self.managedObjectContext];
        playlistTopMostPlayed.iPlaylistId = [NSString stringWithFormat:@"%@ - %d",[Utils getTimestamp],kPlaylistTypeTopMostPlayed];
        playlistTopMostPlayed.iPlaylistType = @(kPlaylistTypeTopMostPlayed);
        playlistTopMostPlayed.sPlaylistName = @"Top 25 Most Played";
        playlistTopMostPlayed.isSmartPlaylist = @YES;
    }
}

- (Playlist *)getPlaylistWithType:(kPlaylistType)iPlaylistType andName:(NSString *)sName
{
    NSFetchRequest *fetchSongRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Playlist class])];
    
    NSMutableArray *predicates = [NSMutableArray new];
    [predicates addObject:[NSPredicate predicateWithFormat:@"iPlaylistType == %d",iPlaylistType]];
    if (sName) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"sPlaylistName ==[c] %@",sName]];
    }
    [fetchSongRequest setPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:predicates]];
    
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
    
    NSSortDescriptor *sortByType = [[NSSortDescriptor alloc] initWithKey:@"iPlaylistType" ascending:YES];
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"sPlaylistName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    [request setSortDescriptors:@[sortByType,sortByName]];
    
    if (isNormalOnly) {
        [request setPredicate:[NSPredicate predicateWithFormat:@"isSmartPlaylist == NO"]];
    }
    
    return request;
}

- (void)removeItemFromPlaylist:(Item *)item
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

- (void)addItem:(Item *)newSong toSpecialList:(kPlaylistType)iPlaylistType
{
    Playlist *playlist = [self getPlaylistWithType:iPlaylistType andName:nil];
    if (!playlist)
    {
        playlist = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Playlist class]) inManagedObjectContext:self.managedObjectContext];
        playlist.iPlaylistId = [NSString stringWithFormat:@"%@ - %d",[Utils getTimestamp],iPlaylistType];
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
        [listSong addObject:newSong.iSongId];
        fDuration = [playlist.fDuration intValue] + [newSong.fDuration intValue];
    }
    else if (iPlaylistType == kPlaylistTypeRecentlyPlayed) {
        if ([listSong containsObject:newSong.iSongId]) {
            [listSong removeObject:newSong.iSongId];
            [listSong addObject:newSong.iSongId];
        }
        else {
            [listSong addObject:newSong.iSongId];
            fDuration += [newSong.fDuration intValue];
        }
    }
    else if (iPlaylistType == kPlaylistTypeTopMostPlayed) {
        if ([listSong containsObject:newSong.iSongId]) {
            [listSong removeObject:newSong.iSongId];
            [listSong addObject:newSong.iSongId];
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
            [listSong addObject:newSong.iSongId];
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
        [[GlobalParameter sharedInstance] setCurrentPlaying:(Item *)item];
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

- (BOOL)doSwipeActionWithItem:(id)itemObj atIndex:(NSInteger)index fromNavigation:(UINavigationController *)navController
{
    if ([itemObj isKindOfClass:[Item class]] || [itemObj isKindOfClass:[FileObj class]])
    {
        Item *item = nil;
        
        if ([itemObj isKindOfClass:[Item class]]) {
            item = (Item *)itemObj;
        }
        else if ([itemObj isKindOfClass:[FileObj class]]) {
            FileObj *file = (FileObj *)itemObj;
            item = file.item;
        }
        
        if (!item) {
            return YES;
        }
        
        if (item.isCloud) {
            if (index == 0) {
                [self deleteSong:item];
                return NO;
            }
            else if (index == 1) {
                AddToPlaylistViewController *vc = [[AddToPlaylistViewController alloc] init];
                vc.value = item;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [navController presentViewController:nav animated:YES completion:nil];
            }
            else if (index == 2) {
                EditViewController *vc = [[EditViewController alloc] init];
                vc.song = item;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [navController presentViewController:nav animated:YES completion:nil];
            }
        }
        else {
            AddToPlaylistViewController *vc = [[AddToPlaylistViewController alloc] init];
            vc.value = item;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [navController presentViewController:nav animated:YES completion:nil];
        }
    }
    else if ([itemObj isKindOfClass:[AlbumObj class]])
    {
        AlbumObj *album = (AlbumObj *)itemObj;
        
        if (album.isCloud) {
            if (index == 0) {
                [self deleteAlbum:album];
                return NO;
            }
            else if (index == 1) {
                AddToPlaylistViewController *vc = [[AddToPlaylistViewController alloc] init];
                vc.value = album;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [navController presentViewController:nav animated:YES completion:nil];
            }
            else if (index == 2) {
                EditViewController *vc = [[EditViewController alloc] init];
                vc.album = album;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [navController presentViewController:nav animated:YES completion:nil];
            }
        }
        else {
            AddToPlaylistViewController *vc = [[AddToPlaylistViewController alloc] init];
            vc.value = album;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [navController presentViewController:nav animated:YES completion:nil];
        }
    }
    else if ([itemObj isKindOfClass:[AlbumArtistObj class]])
    {
        AlbumArtistObj *artist = (AlbumArtistObj *)itemObj;
        
        if (artist.isCloud) {
            if (index == 0) {
                [self deleteArtist:artist];
                return NO;
            }
            else if (index == 1) {
                AddToPlaylistViewController *vc = [[AddToPlaylistViewController alloc] init];
                vc.value = artist;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [navController presentViewController:nav animated:YES completion:nil];
            }
        }
        else {
            AddToPlaylistViewController *vc = [[AddToPlaylistViewController alloc] init];
            vc.value = artist;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [navController presentViewController:nav animated:YES completion:nil];
        }
    }
    else if ([itemObj isKindOfClass:[GenreObj class]])
    {
        GenreObj *genre = (GenreObj *)itemObj;
        
        if (genre.isCloud) {
            if (index == 0) {
                [self deleteGenre:genre];
                return NO;
            }
            else if (index == 1) {
                AddToPlaylistViewController *vc = [[AddToPlaylistViewController alloc] init];
                vc.value = genre;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [navController presentViewController:nav animated:YES completion:nil];
            }
        }
        else {
            AddToPlaylistViewController *vc = [[AddToPlaylistViewController alloc] init];
            vc.value = genre;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [navController presentViewController:nav animated:YES completion:nil];
        }
    }
    
    return YES;
}

- (void)doUtility:(int)iType withData:(NSArray *)arrData fromNavigation:(UINavigationController *)navController
{
    if (iType == kHeaderUtilTypeShuffle) {
        // Play
    }
    else if (iType == kHeaderUtilTypeCreatePlaylist) {
        MakePlaylistViewController *vc = [[MakePlaylistViewController alloc] init];
        vc.arrListItem = arrData;
        [navController pushViewController:vc animated:YES];
    }
    else if (iType == kHeaderUtilTypeGoAllAlbums) {
        AlbumsViewController *vc = [[AlbumsViewController alloc] init];
        [navController pushViewController:vc animated:YES];
    }
    else if (iType == kHeaderUtilTypeGoAllSongs) {
        SongsViewController *vc = [[SongsViewController alloc] init];
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

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

static DataManagement *_sharedInstance = nil;

@interface DataManagement()

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

#pragma mark - Data Method

- (void)removeAllData
{
    NSFetchRequest *fetchSongRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Item class])];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"isCloud",@NO];
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
}

- (NSArray *)getListAlbumFilterByName:(NSString *)sName
{
    NSEntityDescription *itemEntity = [self itemEntity];
    
    NSAttributeDescription *iAlbumId = [itemEntity.attributesByName objectForKey:@"iAlbumId"];
    NSAttributeDescription *sAlbumName = [itemEntity.attributesByName objectForKey:@"sAlbumName"];
    NSAttributeDescription *sArtistName = [itemEntity.attributesByName objectForKey:@"sAlbumArtistName"];
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
    
    NSExpression *listCloud = [NSExpression expressionForKeyPath:@"isCloud"];
    NSExpression *cloudExpression = [NSExpression expressionForFunction:@"max:" arguments:@[listCloud]];
    NSExpressionDescription *cloud = [[NSExpressionDescription alloc] init];
    [cloud setName: @"isCloud"];
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
    [request setPropertiesToFetch:@[iAlbumId,sAlbumName,sArtistName,iYear,numberOfSong,duration,artwork]];
    [request setPropertiesToGroupBy:@[iAlbumId,sAlbumName,sArtistName,iYear]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sAlbumNameIndex" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setResultType:NSDictionaryResultType];

    NSArray *results = nil;
    
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:request error:nil];
    if (sName) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sAlbumName like %@",sName];
        results = [fetchedObjects filteredArrayUsingPredicate:predicate];
    }
    else {
        results = fetchedObjects;
    }
    
    NSMutableArray *albumsArray = [NSMutableArray new];
    for (NSDictionary *albumInfo in results) {
        AlbumObj *albumObj = [[AlbumObj alloc] initWithInfo:albumInfo];
        if (!albumObj) {
            continue;
        }
        [albumsArray addObject:albumObj];
    }
    
    return albumsArray;
}

- (NSArray *)getListArtistFilterByName:(NSString *)sName
{
    NSEntityDescription *itemEntity = [self itemEntity];
    
    NSAttributeDescription *iAlbumId = [itemEntity.attributesByName objectForKey:@"iAlbumId"];
    NSAttributeDescription *sAlbumName = [itemEntity.attributesByName objectForKey:@"sAlbumName"];
    NSAttributeDescription *sArtistName = [itemEntity.attributesByName objectForKey:@"sAlbumArtistName"];
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
    
    NSExpression *listCloud = [NSExpression expressionForKeyPath:@"isCloud"];
    NSExpression *cloudExpression = [NSExpression expressionForFunction:@"max:" arguments:@[listCloud]];
    NSExpressionDescription *cloud = [[NSExpressionDescription alloc] init];
    [cloud setName: @"isCloud"];
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
    [request setPropertiesToFetch:@[iAlbumId,sAlbumName,sArtistName,iYear,numberOfSong,duration,artwork]];
    [request setPropertiesToGroupBy:@[iAlbumId,sAlbumName,sArtistName,iYear]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sAlbumNameIndex" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setResultType:NSDictionaryResultType];
    
    NSArray *results = nil;
    
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:request error:nil];
    if (sName) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sAlbumName like %@",sName];
        results = [fetchedObjects filteredArrayUsingPredicate:predicate];
    }
    else {
        results = fetchedObjects;
    }
    
    NSMutableArray *albumsArray = [NSMutableArray new];
    for (NSDictionary *albumInfo in results) {
        AlbumObj *albumObj = [[AlbumObj alloc] initWithInfo:albumInfo];
        if (!albumObj) {
            continue;
        }
        [albumsArray addObject:albumObj];
    }
    
    return albumsArray;
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

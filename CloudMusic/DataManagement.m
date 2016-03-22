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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%d != %d", @"iType",kSourceTypeCloud];
    [fetchSongRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [[self managedObjectContext] executeFetchRequest:fetchSongRequest error:&error];
    
    if (!error) {
        for (Item *item in listData) {
            [[self managedObjectContext] deleteObject:item];
            
//            NSArray *keys = [[[item entity] attributesByName] allKeys];
//            NSDictionary *dict = [item dictionaryWithValuesForKeys:keys];
//            NSLog(@"%@",dict);
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

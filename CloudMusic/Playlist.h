//
//  Playlist.h
//  CloudMusic
//
//  Created by TuanTN on 4/18/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

typedef enum {
    kPlaylistTypeNormal,
    kPlaylistTypeMyTopRated,
    kPlaylistTypeRecentlyAdded,
    kPlaylistTypeRecentlyPlayed,
    kPlaylistTypeTopMostPlayed,
} kPlaylistType;

NS_ASSUME_NONNULL_BEGIN

@interface Playlist : NSManagedObject

@property (nonatomic, strong) NSURL *sLocalArtworkUrl;
@property (nonatomic, strong) NSString *sPlaylistDesc;

- (void)setPlaylist:(NSArray *)listSong;
- (NSArray *)getPlaylist;

- (void)setArtwork:(nullable NSString *)sArtworkName;

@end

NS_ASSUME_NONNULL_END

#import "Playlist+CoreDataProperties.h"


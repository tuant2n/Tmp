//
//  Playlist.h
//  CloudMusic
//
//  Created by TuanTN on 4/18/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Playlist : NSManagedObject

- (void)setPlaylist:(NSArray *)listSong;
- (NSArray *)getPlaylist;

@end

NS_ASSUME_NONNULL_END

#import "Playlist+CoreDataProperties.h"


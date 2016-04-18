//
//  Playlist+CoreDataProperties.h
//  CloudMusic
//
//  Created by TuanTN on 4/18/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Playlist.h"

NS_ASSUME_NONNULL_BEGIN

@interface Playlist (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *iPlaylistId;
@property (nullable, nonatomic, retain) NSString *sPlaylistName;
@property (nullable, nonatomic, retain) NSString *sArtworkName;
@property (nullable, nonatomic, retain) id listSong;
@property (nullable, nonatomic, retain) NSNumber *iPlaylistType;
@property (nullable, nonatomic, retain) NSNumber *fDuration;
@property (nullable, nonatomic, retain) NSNumber *isSmartPlaylist;

@end

NS_ASSUME_NONNULL_END

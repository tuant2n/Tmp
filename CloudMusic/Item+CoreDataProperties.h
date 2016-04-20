//
//  Item+CoreDataProperties.h
//  CloudMusic
//
//  Created by TuanTN on 4/4/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Item.h"

@class File;

NS_ASSUME_NONNULL_BEGIN

@interface Item (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *fDuration;
@property (nullable, nonatomic, retain) NSString *iAlbumArtistId;
@property (nullable, nonatomic, retain) NSString *iAlbumId;
@property (nullable, nonatomic, retain) NSString *iArtistId;
@property (nullable, nonatomic, retain) NSNumber *iCloudItem;
@property (nullable, nonatomic, retain) NSString *iGenreId;
@property (nullable, nonatomic, retain) NSNumber *iPlayCount;
@property (nullable, nonatomic, retain) NSString *iPlaylistId;
@property (nullable, nonatomic, retain) NSNumber *iRate;
@property (nullable, nonatomic, retain) NSString *iSongId;
@property (nullable, nonatomic, retain) NSNumber *iYear;
@property (nullable, nonatomic, retain) NSNumber *lTimeDownloaded;
@property (nullable, nonatomic, retain) NSString *sAlbumArtistName;
@property (nullable, nonatomic, retain) NSString *sAlbumArtistNameIndex;
@property (nullable, nonatomic, retain) NSString *sAlbumName;
@property (nullable, nonatomic, retain) NSString *sAlbumNameIndex;
@property (nullable, nonatomic, retain) NSString *sArtistName;
@property (nullable, nonatomic, retain) NSString *sArtistNameIndex;
@property (nullable, nonatomic, retain) NSString *sArtworkName;
@property (nullable, nonatomic, retain) NSString *sAssetUrl; // URL
@property (nullable, nonatomic, retain) NSString *sDuration;
@property (nullable, nonatomic, retain) NSString *sGenreName;
@property (nullable, nonatomic, retain) NSString *sGenreNameIndex;
@property (nullable, nonatomic, retain) NSString *sLyrics;
@property (nullable, nonatomic, retain) NSString *sPlaylistName;
@property (nullable, nonatomic, retain) NSString *sSongFirstLetter;
@property (nullable, nonatomic, retain) NSString *sSongName;
@property (nullable, nonatomic, retain) NSString *sSongNameIndex;
@property (nullable, nonatomic, retain) File *fileInfo;

@end

NS_ASSUME_NONNULL_END

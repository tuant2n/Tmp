//
//  Item+CoreDataProperties.m
//  CloudMusic
//
//  Created by TuanTN on 3/20/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Item+CoreDataProperties.h"

#import "MPMediaItem+Accessors.h"

@implementation Item (CoreDataProperties)

@dynamic sSongName;
@dynamic sPlaylistName;
@dynamic sLyrics;
@dynamic sGenreName;
@dynamic sAssetUrl;
@dynamic sArworkName;
@dynamic sArtistName;
@dynamic sAlbumName;
@dynamic iType;
@dynamic iTrack;
@dynamic iSongId;
@dynamic iRate;
@dynamic iPlaylistId;
@dynamic iPlayCount;
@dynamic iGenreId;
@dynamic iArtistId;
@dynamic iAlbumId;
@dynamic fDuration;

@end

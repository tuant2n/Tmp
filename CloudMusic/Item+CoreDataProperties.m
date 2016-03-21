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
#import "Utils.h"

@implementation Item (CoreDataProperties)

@dynamic sAssetUrl;
@dynamic iType;

@dynamic iSongId;
@dynamic sSongName;
@dynamic sSongNameIndex;
@dynamic sSongFirstLetter;

@dynamic iAlbumId;
@dynamic sAlbumName;
@dynamic sAlbumNameIndex;

@dynamic iAlbumArtistId;
@dynamic sAlbumArtistName;

@dynamic sPlaylistName;
@dynamic sLyrics;
@dynamic sGenreName;

@dynamic sArworkName;
@dynamic sArtistName;

@dynamic iTrack;
@dynamic iRate;
@dynamic iPlaylistId;
@dynamic iPlayCount;
@dynamic iGenreId;
@dynamic iArtistId;

@dynamic fDuration;

@end

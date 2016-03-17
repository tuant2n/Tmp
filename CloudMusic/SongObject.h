//
//  SongObject.h
//  CloudMusic
//
//  Created by TuanTN on 3/17/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SongObject : NSObject

@property (nonatomic, strong) NSNumber *iSongId;
@property (nonatomic, strong) NSString *sSongTitle;
@property (nonatomic, strong) NSURL *sAssetUrl;
@property (nonatomic, strong) UIImage *imgArtwork;
@property (nonatomic, assign) BOOL isDownloaded;

@property (nonatomic, assign) long lPlayCount;
@property (nonatomic, assign) int iRating;
@property (nonatomic, assign) float fDuration;
@property (nonatomic, assign) int iTrack;

@property (nonatomic, strong) NSString *sLyrics;
@property (nonatomic, assign) int iYear;

@property (nonatomic, strong) NSNumber *iArtistPID;
@property (nonatomic, strong) NSString *sArtist;

@property (nonatomic, strong) NSNumber *iAlbumId;
@property (nonatomic, strong) NSString *sAlbumTitle;

@property (nonatomic, strong) NSNumber *iGenreId;
@property (nonatomic, strong) NSString *sGenre;

@property (nonatomic, strong) NSNumber *iAlbumArtistId;
@property (nonatomic, strong) NSString *sAlbumArtist;

- (id)initWithInfo:(NSDictionary *)songInfo;

@end

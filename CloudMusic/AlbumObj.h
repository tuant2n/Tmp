//
//  AlbumObj.h
//  CloudMusic
//
//  Created by TuanTN on 3/26/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumObj : NSObject

@property (nonatomic, strong) NSString *iAlbumId, *iArtistId, *iGenreId;
@property (nonatomic, strong) NSString *sAlbumName, *sAlbumArtistName;
@property (nonatomic, strong) NSURL *sLocalArtworkUrl;

@property (nonatomic, strong) NSNumber *iYear;
@property (nonatomic, strong) NSString *sAlbumDesc, *sAlbumInfo;

@property (nonatomic, assign) BOOL isCloud, isPlaying;

- (id)initWithInfo:(NSDictionary *)info;

@end

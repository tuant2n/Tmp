//
//  AlbumObj.h
//  CloudMusic
//
//  Created by TuanTN on 3/26/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumObj : NSObject

@property (nonatomic, strong) NSNumber *iAlbumId;
@property (nonatomic, strong) NSString *sAlbumName, *sAlbumArtistName;
@property (nonatomic, strong) NSURL *sLocalArtworkUrl;

@property (nonatomic, assign) BOOL isCloud, isPlaying;
@property (nonatomic, assign) int iYear;
@property (nonatomic, strong) NSString *sAlbumDesc, *sAlbumInfo;

- (id)initWithInfo:(NSDictionary *)info;

@end

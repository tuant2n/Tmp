//
//  AlbumArtistObj.h
//  CloudMusic
//
//  Created by TuanTN8 on 3/28/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumArtistObj : NSObject

@property (nonatomic, strong) NSNumber *iAlbumArtistId;
@property (nonatomic, strong) NSString *sAlbumArtistName, *sAlbumArtistDesc;
@property (nonatomic, strong) NSURL *sLocalArtworkUrl;
@property (nonatomic, assign) int  numberOfAlbum;

@property (nonatomic, assign) BOOL isCloud, isPlaying;

- (id)initWithInfo:(NSDictionary *)info;

@end

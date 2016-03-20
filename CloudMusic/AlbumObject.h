//
//  AlbumObject.h
//  CloudMusic
//
//  Created by TuanTN on 3/17/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AlbumObject : NSObject

@property (nonatomic, strong) NSNumber *iAlbumId;
@property (nonatomic, strong) NSString *sAlbumTitle;

@property (nonatomic, strong) NSNumber *iAlbumArtistId;
@property (nonatomic, strong) NSString *sAlbumArtist;

@property (nonatomic, strong) UIImage *imgArtwork;

@property (nonatomic, assign) int iTrackCount;
@property (nonatomic, assign) int iYear;

@property (nonatomic, assign) float fDuration;
@property (nonatomic, strong) NSString *sDescription;

@property (nonatomic, strong) NSArray *listSong;

- (id)initWithInfo:(NSDictionary *)albumInfo;

@end

//
//  ArtistObject.h
//  CloudMusic
//
//  Created by TuanTN8 on 3/19/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ArtistObject : NSObject

@property (nonatomic, strong) NSNumber *iArtistId;
@property (nonatomic, strong) NSString *sArtist;
@property (nonatomic, strong) UIImage *imgArtwork;

@property (nonatomic, assign) int iTrackCount;
@property (nonatomic, assign) int iYear;

@property (nonatomic, assign) float fDuration;
@property (nonatomic, strong) NSString *sDescription;

@property (nonatomic, strong) NSArray *listSong;

- (id)initWithInfo:(NSDictionary *)artistInfo;

@end

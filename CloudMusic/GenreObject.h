//
//  GenreObject.h
//  CloudMusic
//
//  Created by TuanTN8 on 3/19/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GenreObject : NSObject

@property (nonatomic, strong) NSNumber *iGenreId;
@property (nonatomic, strong) NSString *sGenre;
@property (nonatomic, strong) UIImage *imgArtwork;

@property (nonatomic, assign) int iTrackCount;
@property (nonatomic, assign) int iYear;

@property (nonatomic, assign) float fDuration;
@property (nonatomic, strong) NSString *sDescription;

@property (nonatomic, strong) NSArray *listSong;

- (id)initWithInfo:(NSDictionary *)genreInfo;

@end

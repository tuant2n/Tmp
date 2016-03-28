//
//  GenresObj.h
//  CloudMusic
//
//  Created by TuanTN on 3/28/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenresObj : NSObject

@property (nonatomic, strong) NSNumber *iGenreId;
@property (nonatomic, strong) NSString *sGenreName, *sGenreDesc;
@property (nonatomic, strong) NSURL *sLocalArtworkUrl;

@property (nonatomic, assign) BOOL isCloud, isPlaying;

- (id)initWithInfo:(NSDictionary *)info;

@end

//
//  GlobalParameter.h
//  CloudMusic
//
//  Created by TuanTN on 3/11/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GlobalParameter : NSObject

@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSMutableArray *arrListSong, *arrListAlbum, *arrListArtist, *arrListGenre;

+ (GlobalParameter *)sharedInstance;

#pragma mark - Play State

- (void)startPlay;
- (void)pausePlay;
- (BOOL)isPlay;

@end

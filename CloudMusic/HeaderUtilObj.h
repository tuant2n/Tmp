//
//  HeaderUtilObj.h
//  CloudMusic
//
//  Created by TuanTN8 on 3/25/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    kHeaderUtilTypeEdit = 0,
    kHeaderUtilTypeShuffle = 1,
    kHeaderUtilTypeGoAllAlbums = 2,
    kHeaderUtilTypeGoAllSongs = 3,
    kHeaderUtilTypeCreatePlaylist = 4,
} kHeaderUtilType;

@interface HeaderUtilObj : NSObject

@property (nonatomic, strong) NSString *sTitle;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, assign) kHeaderUtilType iType;

- (id)initWithTitle:(NSString *)sTitle icon:(NSString *)sIconName type:(kHeaderUtilType)iType;

@end

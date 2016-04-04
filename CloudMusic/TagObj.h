//
//  TabObj.h
//  CloudMusic
//
//  Created by TuanTN8 on 4/2/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kTagTypeTitle,
    kTagTypeArtist,
    kTagTypeAlbumArtist,
    kTagTypeAlbum,
    kTagTypeTrack,
    kTagTypeGenre,
    kTagTypeFolderName,
    kTagTypeFilename,
    kTagTypeTime,
    kTagTypeKind,
    kTagTypeSize,
    kTagTypeBiteRate,
    kTagTypeNumberOfPlay,
    kTagTypeLyrics
} kTagType;

@interface TagObj : NSObject

@end

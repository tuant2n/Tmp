//
//  TabObj.h
//  CloudMusic
//
//  Created by TuanTN8 on 4/2/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kTagTypeElement,
    kTagTypeWriteTags,
    kTagTypeRename,
    kTagTypeLyrics,
    kTagTypeDelete,
} kTagType;

typedef enum {
    kElementTypeNone,
    kElementTypeTitle,
    kElementTypeArtist,
    kElementTypeAlbumArtist,
    kElementTypeAlbum,
    kElementTypeYear,
    kElementTypeGenre,
    kElementTypeTime,
    kElementTypeSize,
    kElementTypePlayed,
} kElementType;

@interface TagObj : NSObject

@property (nonatomic, assign) kTagType iTagType;
@property (nonatomic, assign) kElementType iElementType;

@property (nonatomic, assign) BOOL isEditable;
@property (nonatomic, strong) id value;

@end

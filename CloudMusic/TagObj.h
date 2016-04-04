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
    kTagTypeAction,
    kTagTypeSaveToFile,
} kTagType;

typedef enum {
    kElementTypeNone,
    kElementTypeTitle,
    kElementTypeArtist,
    kElementTypeAlbumArtist,
    kElementTypeAlbum,
    kElementTypeTrack,
    kElementTypeYear,
    kElementTypeGenre,
    kElementTypeFolderName,
    kElementTypeFilename,
    kElementTypeTime,
    kElementTypeKind,
    kElementTypeSize,
    kElementTypeBitRate,
    kElementTypePlayed,
    kElementTypeLyrics
} kElementType;

typedef enum {
    kTagActionTypeNone,
    kTagActionTypeDelete,
    kTagActionTypeWriteTitle,
} kTagActionType;

@interface TagObj : NSObject

@property (nonatomic, assign) kTagType iTagType;
@property (nonatomic, assign) kElementType iElementType;
@property (nonatomic, assign) kTagActionType iTagActionType;

@property (nonatomic, assign) BOOL isEditable;
@property (nonatomic, strong) id value;

@end

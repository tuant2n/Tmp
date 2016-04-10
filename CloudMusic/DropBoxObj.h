//
//  DropBoxObj.h
//  CloudMusic
//
//  Created by TuanTN on 4/9/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBMetadata;

typedef enum {
    kFileTypeFolder,
    kFileTypeMP3,
    kFileTypeM4A,
    kFileTypeWMA,
    kFileTypeWAV,
    kFileTypeAAC,
    kFileTypeOGG
} kFileType;

@interface DropBoxObj : NSObject

@property (nonatomic, strong) DBMetadata *metaData;

@property (nonatomic, strong) NSString *sFileName, *sDesc;
@property (nonatomic, strong) NSString *sDownloadPath;

@property (nonatomic, assign) kFileType iType;
@property (nonatomic, assign) BOOL isDirectory;

@property (nonatomic, assign) BOOL isSelected, isDownloadSuccess;
@property (nonatomic, assign) float fProgress;

- (id)initWithMetadata:(DBMetadata *)metadata;

@end

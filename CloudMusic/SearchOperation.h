//
//  SearchOperation.h
//  CloudMusic
//
//  Created by TuanTN on 3/28/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kSearchTypeNone,
    kSearchTypeFile,
    kSearchTypeSong,
    kSearchTypeAlbum,
    kSearchTypeArtist,
    kSearchTypeGenre,
} kSearchType;

@interface SearchOperation : NSOperation

@property (nonatomic, strong) NSMutableArray *resultArray;

- (id)initWitSearchString:(NSString *)sSearch searchType:(kSearchType)iType;

@end

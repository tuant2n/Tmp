//
//  SearchOperation.m
//  CloudMusic
//
//  Created by TuanTN on 3/28/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "SearchOperation.h"

#import "DataManagement.h"
#import "DataObj.h"

#import "Utils.h"

@interface SearchOperation()

@property (nonatomic, strong) NSString *sSearch;
@property (nonatomic, assign) kSearchType iSearchType;

@end

@implementation SearchOperation

- (id)initWitSearchString:(NSString *)sSearch searchType:(kSearchType)iSearchType
{
    self = [super init];
    if (self) {
        self.sSearch = sSearch;
        self.iSearchType = iSearchType;
    }
    return self;
}

- (void)main
{
    @autoreleasepool
    {
        if (_sSearch == nil) {
            return;
        }
        
        _sSearch = [[Utils standardLocaleString:_sSearch] lowercaseString];

        if (_sSearch.length <= 0) {
            return;
        }
        
        if (self.isCancelled) {
            return;
        }
    
        NSMutableArray *results = [[NSMutableArray alloc] init];
        
        NSArray *tmpArray = nil;
        
        tmpArray = [[DataManagement sharedInstance] getListSongFilterByName:_sSearch albumId:nil artistId:nil genreId:nil];
        if (tmpArray.count > 0)
        {
            DataObj *songResult = [[DataObj alloc] init];
            songResult.listData = tmpArray;
            songResult.sTitle = [NSString stringWithFormat:@"Songs (result: %d)",(int)tmpArray.count];
            songResult.iOrder = (self.iSearchType == kSearchTypeSong) ? 1 : 0;
            [results addObject:songResult];
        }
        
        if (self.isCancelled) {
            return;
        }
        
        tmpArray = [[DataManagement sharedInstance] getListAlbumFilterByName:_sSearch albumArtistId:nil genreId:nil];
        if (tmpArray.count > 0)
        {
            DataObj *albumResult = [[DataObj alloc] init];
            albumResult.listData = tmpArray;
            albumResult.sTitle = [NSString stringWithFormat:@"Albums (result: %d)",(int)tmpArray.count];
            albumResult.iOrder = (self.iSearchType == kSearchTypeAlbum) ? 1 : 0;
            [results addObject:albumResult];
        }
        
        if (self.isCancelled) {
            return;
        }
        
        tmpArray = [[DataManagement sharedInstance] getListAlbumArtistFilterByName:_sSearch];
        if (tmpArray.count > 0)
        {
            DataObj *artistResult = [[DataObj alloc] init];
            artistResult.listData = tmpArray;
            artistResult.sTitle = [NSString stringWithFormat:@"Artists (result: %d)",(int)tmpArray.count];
            artistResult.iOrder = (self.iSearchType == kSearchTypeArtist) ? 1 : 0;
            [results addObject:artistResult];
        }
        
        if (self.isCancelled) {
            return;
        }
        
        tmpArray = [[DataManagement sharedInstance] getListFileFilterByName:_sSearch];
        if (tmpArray.count > 0)
        {
            DataObj *fileResult = [[DataObj alloc] init];
            fileResult.listData = tmpArray;
            fileResult.sTitle = [NSString stringWithFormat:@"Files (result: %d)",(int)tmpArray.count];
            fileResult.iOrder = (self.iSearchType == kSearchTypeFile) ? 1 : 0;
            [results addObject:fileResult];
        }
        
        if (self.isCancelled) {
            return;
        }
        
        tmpArray = [[DataManagement sharedInstance] getListGenreFilterByName:_sSearch];
        if (tmpArray.count > 0)
        {
            DataObj *genreResult = [[DataObj alloc] init];
            genreResult.listData = tmpArray;
            genreResult.sTitle = [NSString stringWithFormat:@"Genres (result: %d)",(int)tmpArray.count];
            genreResult.iOrder = (self.iSearchType == kSearchTypeGenre) ? 1 : 0;
            [results addObject:genreResult];
        }
        
        if (self.isCancelled) {
            return;
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"iOrder" ascending:NO];
        NSArray *sortedArray = [results sortedArrayUsingDescriptors:@[sortDescriptor]];
        _resultArray = [[NSMutableArray alloc] initWithArray:sortedArray];
    }
}

@end

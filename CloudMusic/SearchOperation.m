//
//  SearchOperation.m
//  CloudMusic
//
//  Created by TuanTN on 3/28/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "SearchOperation.h"

#import "DataManagement.h"
#import "SearchResultObj.h"

#import "Utils.h"

@interface SearchOperation()

@property (nonatomic, strong) NSString *sSearch;

@end

@implementation SearchOperation

- (id)initWitSearchString:(NSString *)sSearch
{
    self = [super init];
    if (self) {
        self.sSearch = sSearch;
    }
    return self;
}

- (void)main {
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
        
        _resultArray = [[NSMutableArray alloc] init];
        
        NSArray *tmpArray = nil;
        
        tmpArray = [[DataManagement sharedInstance] getListSongFilterByName:_sSearch];
        if (tmpArray.count > 0) {
            SearchResultObj *songResult = [[SearchResultObj alloc] init];
            songResult.resuls = tmpArray;
            songResult.sTitle = [NSString stringWithFormat:@"Songs (result: %d)",(int)tmpArray.count];
            [_resultArray addObject:songResult];
        }
        
        if (self.isCancelled) {
            return;
        }
        
        tmpArray = [[DataManagement sharedInstance] getListAlbumFilterByName:_sSearch artistId:nil genreId:nil];
        if (tmpArray.count > 0) {
            SearchResultObj *albumResult = [[SearchResultObj alloc] init];
            albumResult.resuls = tmpArray;
            albumResult.sTitle = [NSString stringWithFormat:@"Albums (result: %d)",(int)tmpArray.count];
            [_resultArray addObject:albumResult];
        }
        
        if (self.isCancelled) {
            return;
        }
        
        tmpArray = [[DataManagement sharedInstance] getListAlbumArtistFilterByName:_sSearch];
        if (tmpArray.count > 0) {
            SearchResultObj *artistResult = [[SearchResultObj alloc] init];
            artistResult.resuls = tmpArray;
            artistResult.sTitle = [NSString stringWithFormat:@"Artists (result: %d)",(int)tmpArray.count];
            [_resultArray addObject:artistResult];
        }
        
        if (self.isCancelled) {
            return;
        }
        
        tmpArray = [[DataManagement sharedInstance] getListGenreFilterByName:_sSearch];
        if (tmpArray.count > 0) {
            SearchResultObj *genreResult = [[SearchResultObj alloc] init];
            genreResult.resuls = tmpArray;
            genreResult.sTitle = [NSString stringWithFormat:@"Genres (result: %d)",(int)tmpArray.count];
            [_resultArray addObject:genreResult];
        }
        
        if (self.isCancelled) {
            return;
        }
    }
}

@end

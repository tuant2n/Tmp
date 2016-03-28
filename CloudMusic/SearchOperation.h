//
//  SearchOperation.h
//  CloudMusic
//
//  Created by TuanTN on 3/28/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchOperation : NSOperation

@property (nonatomic, strong) NSMutableArray *resultArray;
- (id)initWitSearchString:(NSString *)sSearch;

@end

//
//  SearchResultObj.h
//  CloudMusic
//
//  Created by TuanTN on 3/28/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataObj : NSObject

@property (nonatomic, strong) NSString *sTitle;
@property (nonatomic, strong) NSArray *listData;
@property (nonatomic, assign) int iOrder;

@end

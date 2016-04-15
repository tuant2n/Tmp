//
//  FileObj.h
//  CloudMusic
//
//  Created by TuanTN8 on 4/15/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;

@interface FileObj : NSObject

@property (nonatomic, strong) Item *item;

- (id)initWithItem:(Item *)item;

@end

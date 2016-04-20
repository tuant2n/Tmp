//
//  FileInfo.h
//  CloudMusic
//
//  Created by TuanTN on 4/4/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;
@class DropBoxObj;

NS_ASSUME_NONNULL_BEGIN

@interface File : NSManagedObject

@property (nonatomic, strong) NSString *sTimeStamp;

- (void)updateFileInfo:(DropBoxObj *)item;

@end

NS_ASSUME_NONNULL_END

#import "File+CoreDataProperties.h"

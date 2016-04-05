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

NS_ASSUME_NONNULL_BEGIN

@interface FileInfo : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

- (void)updateFileInfo:(NSString *)sFilePath;

@end

NS_ASSUME_NONNULL_END

#import "FileInfo+CoreDataProperties.h"

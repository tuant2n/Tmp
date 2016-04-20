//
//  FileInfo+CoreDataProperties.h
//  CloudMusic
//
//  Created by TuanTN on 4/4/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "File.h"

NS_ASSUME_NONNULL_BEGIN

@interface File (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *sFileName;
@property (nullable, nonatomic, retain) NSString *sSize;
@property (nullable, nonatomic, retain) NSNumber *lTimestamp;

@property (nullable, nonatomic, retain) Item *item;

@end

NS_ASSUME_NONNULL_END

//
//  Item.h
//  CloudMusic
//
//  Created by TuanTN on 3/20/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface Item : NSManagedObject

@property (nonatomic, strong) NSURL *sLocalArtworkUrl;
@property (nonatomic, strong) NSAttributedString *sSongDesc;;

@property (nonatomic, assign) BOOL isPlaying;

- (void)updateWithMediaItem:(MPMediaItem *)item;

@end

NS_ASSUME_NONNULL_END

#import "Item+CoreDataProperties.h"

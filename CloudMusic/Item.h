//
//  Item.h
//  CloudMusic
//
//  Created by TuanTN on 3/20/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class DropBoxObj;

@interface Item : NSManagedObject

@property (nonatomic, assign) BOOL isCloud;

@property (nullable, nonatomic, strong) NSURL *sLocalArtworkUrl;
@property (nullable, nonatomic, strong) NSAttributedString *sSongDesc;

@property (nullable, nonatomic, strong) NSURL *sPlayableUrl;

@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) int numberOfSelect;

#pragma mark - Update Item

- (void)updateWithMediaItem:(MPMediaItem *)item;
- (void)updateWithSongUrl:(NSURL *)songUrl songInfo:(NSDictionary *)songInfo;

- (void)setSongName:(NSString *)sSongName;
- (void)setArtwork:(UIImage *)artwork;
- (void)setAlbumName:(NSString *)sAlbumName;
- (void)setArtistName:(NSString *)sArtistName;
- (void)setAlbumArtistName:(NSString *)sAlbumArtistName;

- (void)changeAlbumName:(NSString *)sAlbumName;
- (void)changeArtistName:(NSString *)sArtistName;
- (void)changeAlbumArtistName:(NSString *)sAlbumArtistName;
- (void)changeGenreName:(NSString *)sGenreName;

- (NSArray *)getMetaData;

@end

NS_ASSUME_NONNULL_END

#import "Item+CoreDataProperties.h"

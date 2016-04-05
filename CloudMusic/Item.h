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

@property (nonatomic, assign) BOOL isCloud;

@property (nonatomic, strong) NSURL *sLocalArtworkUrl;
@property (nonatomic, strong) NSAttributedString *sSongDesc;

@property (nonatomic, assign) BOOL isPlaying;

- (void)updateWithMediaItem:(MPMediaItem *)item;

- (void)setSongName:(NSString *)sSongName;
- (void)setArtwork:(UIImage *)artwork;

- (void)changeAlbumName:(NSString *)sAlbumName;
- (void)changeArtistName:(NSString *)sArtistName;
- (void)changeAlbumArtistName:(NSString *)sAlbumArtistName;
- (void)changeGenreName:(NSString *)sGenreName;

@end

NS_ASSUME_NONNULL_END

#import "Item+CoreDataProperties.h"

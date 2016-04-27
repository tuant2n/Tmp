//
//  SongsCell.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/25/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "SongsCell.h"

#import "Item.h"

#import "Utils.h"

@interface SongsCell()
{
    Item *currentSong;
}

@property (nonatomic, weak) IBOutlet UILabel *lblSongName, *lblSongDesc, *lblDuration;

@end

@implementation SongsCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.lblDuration.textColor = [Utils colorWithRGBHex:0x545454];
}

- (void)config:(Item *)song
{
    currentSong = song;
    
    [self configWithoutMenu:currentSong];
    [self configMenuButton:currentSong.isCloud isEdit:YES hasIndexTitle:YES];
}

- (void)configWithoutMenu:(Item *)song
{
    currentSong = song;
    
    [self setArtwork:currentSong.sLocalArtworkUrl];
    
    self.lblSongName.text = currentSong.sSongName;
    self.lblSongDesc.attributedText = currentSong.sSongDesc;
    self.lblDuration.text = currentSong.sDuration;
    
    [self setItemType:currentSong.isCloud];
    [self isPlaying:currentSong.isPlaying];
}

#pragma mark - Observer

- (void)addObserver
{
    [currentSong addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)removeObserver
{
    if (![currentSong observationInfo]) {
        return;
    }
    
    @try {
        [currentSong removeObserver:self forKeyPath:@"isPlaying"];
    }
    @catch (NSException *exception) {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (![object isKindOfClass:[Item class]]) {
        return;
    }
    
    if (![keyPath isEqualToString:@"isPlaying"]) {
        return;
    }
    
    [self isPlaying:currentSong.isPlaying];
}

- (void)dealloc
{
    [self removeObserver];
}

@end

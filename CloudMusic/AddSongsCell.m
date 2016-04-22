//
//  AddSongsCell.m
//  CloudMusic
//
//  Created by TuanTN8 on 4/22/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "AddSongsCell.h"

#import "Item.h"

#import "Utils.h"

@interface AddSongsCell()

@property (nonatomic, weak) IBOutlet UILabel *lblSongName, *lblSongDesc, *lblDuration, *lblCount;

@end

@implementation AddSongsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.lblDuration.textColor = [Utils colorWithRGBHex:0x545454];
}

- (void)configWithoutMenu:(Item *)song
{
    self.currentSong = song;
    
    [self setArtwork:self.currentSong.sLocalArtworkUrl];
    
    self.lblSongName.text = self.currentSong.sSongName;
    self.lblSongDesc.attributedText = self.currentSong.sSongDesc;
    self.lblDuration.text = self.currentSong.sDuration;
    [self setItemType:self.currentSong.isCloud];
    
    [self configNumberOfSelect];
    [self addObserver];
}

- (void)configNumberOfSelect
{
    self.lblCount.hidden = (self.currentSong.numberOfSelect == 0);
    self.lblCount.text = [NSString stringWithFormat:@"x%d",self.currentSong.numberOfSelect];
}

#pragma mark - KVO

- (void)addObserver
{
    if (!self.currentSong) {
        return;
    }
    
    [self.currentSong addObserver:self forKeyPath:@"numberOfSelect" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)removeObserver
{
    if (!self.currentSong) {
        return;
    }
    
    if ([self.currentSong observationInfo]) {
        @try {
            [self.currentSong removeObserver:self forKeyPath:@"numberOfSelect"];
        }
        @catch(id anException) {
            TTLog(@"%@",anException);
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (![object isKindOfClass:[Item class]] && [keyPath isEqualToString:@"numberOfSelect"]) {
        return;
    }
    
    [self configNumberOfSelect];
}

- (void)dealloc
{
    [self removeObserver];
}

@end

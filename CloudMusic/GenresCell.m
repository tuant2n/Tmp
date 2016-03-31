//
//  GenresCell.m
//  CloudMusic
//
//  Created by TuanTN on 3/28/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "GenresCell.h"

#import "GenreObj.h"
#import "Utils.h"

@interface GenresCell()

@property (nonatomic, weak) IBOutlet UILabel *lblGenreName, *lblGenreDesc;

@end

@implementation GenresCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.lblGenreDesc.textColor = [Utils colorWithRGBHex:0x6a6a6a];
}

- (void)config:(GenreObj *)item
{
    [self setArtwork:item.sLocalArtworkUrl];
    
    self.lblGenreName.text = item.sGenreName;
    self.lblGenreDesc.text = item.sGenreDesc;
    
    [self configMenuButton:item.isCloud isEdit:YES];
    [self setItemType:item.isCloud];
    [self isPlaying:item.isPlaying];
}

@end

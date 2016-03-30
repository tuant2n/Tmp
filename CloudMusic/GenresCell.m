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
{
    MGSwipeButton *deleteBtn, *addToPlaylistBtn;
}

@property (nonatomic, weak) IBOutlet UILabel *lblGenreName, *lblGenreDesc;

@end

@implementation GenresCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.lblGenreDesc.textColor = [Utils colorWithRGBHex:0x6a6a6a];

    deleteBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnDelete"] backgroundColor:[Utils colorWithRGBHex:0xFF0000]];
    addToPlaylistBtn = [MGSwipeButton buttonWithTitle:nil icon:[UIImage imageNamed:@"btnAddPlaylist"] backgroundColor:[Utils colorWithRGBHex:0x03C9A9]];
}

- (void)config:(GenreObj *)item
{
    [self setArtwork:item.sLocalArtworkUrl];
    
    self.lblGenreName.text = item.sGenreName;
    self.lblGenreDesc.text = item.sGenreDesc;
    
    if (item.isCloud) {
        self.leftButtons = @[deleteBtn,addToPlaylistBtn];
    }
    else {
        self.leftButtons = @[addToPlaylistBtn];
    }
    
    [self setItemType:item.isCloud];
    [self isPlaying:item.isPlaying];
}

+ (CGFloat)height
{
    return 62.0;
}

@end

//
//  ArtworkView.m
//  CloudMusic
//
//  Created by TuanTN8 on 4/2/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "ArtworkView.h"

#import "Utils.h"

@interface ArtworkView()

@property (nonatomic, weak) IBOutlet UIImageView *imgvArtwork;

@end

@implementation ArtworkView

- (void)awakeFromNib
{
    self.backgroundColor = [Utils colorWithRGBHex:0xf7f7f7];
}

@end

//
//  ArtworkView.h
//  CloudMusic
//
//  Created by TuanTN8 on 4/2/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ArtworkViewDelegate <NSObject>
- (void)changeArtwork;
@end

@interface ArtworkView : UIView

@property (nonatomic, assign) id<ArtworkViewDelegate> delegate;

- (void)setArtwotk:(NSURL *)sUrl;
- (void)setArtworkImage:(UIImage *)image;

- (BOOL)isChangeArtwork;
- (UIImage *)artwork;

@end

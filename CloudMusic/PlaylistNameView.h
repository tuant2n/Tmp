//
//  PlaylistNameView.h
//  CloudMusic
//
//  Created by TuanTN8 on 4/20/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlaylistNameViewDelegate <NSObject>

- (void)didEnterName:(NSString *)sPlaylistName;

@end

@interface PlaylistNameView : UIView

@property (nonatomic, assign) id<PlaylistNameViewDelegate> delegate;

- (NSString *)getPlaylistName;

- (void)configWhenEmpty:(BOOL)isEmpty;
- (void)closeKeyboard;

@end

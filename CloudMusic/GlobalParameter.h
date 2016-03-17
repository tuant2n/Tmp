//
//  GlobalParameter.h
//  CloudMusic
//
//  Created by TuanTN on 3/11/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GlobalParameter : NSObject

@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSMutableArray *arrListSong;

+ (GlobalParameter *)sharedInstance;

#pragma mark - Data

- (void)setupData;

#pragma mark - Play State

- (void)startPlay;
- (void)pausePlay;
- (BOOL)isPlay;

#pragma mark - iTunes Sync

- (void)setLastTimeAppSync:(long)lTime;
- (long)lastTimeAppSync;

#pragma mark - Save Data

- (void)saveData:(NSArray *)listSong;
- (NSArray *)readData;

@end

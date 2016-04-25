//
//  GlobalParameter.h
//  CloudMusic
//
//  Created by TuanTN on 3/11/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DataManagement.h"

@interface GlobalParameter : NSObject

@property (nonatomic, strong) Item *currentItemPlay;

+ (GlobalParameter *)sharedInstance;

#pragma mark - Play State

- (void)startPlay;
- (void)pausePlay;
- (BOOL)isPlay;
- (void)setCurrentPlaying:(Item *)itemObj;
- (void)openPlayer;

#pragma mark - DropBoxInfo

- (void)clearDropBoxInfo;

- (void)setDropBoxName:(NSString *)sName;
- (NSString *)getDropBoxName;

- (void)setDropBoxId:(NSString *)sId;
- (NSString *)getDropBoxId;

@end

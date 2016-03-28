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

@property (nonatomic, strong) Item *currentPlay;

+ (GlobalParameter *)sharedInstance;

#pragma mark - Play State

- (void)startPlay;
- (void)pausePlay;
- (BOOL)isPlay;

@end

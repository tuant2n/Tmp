//
//  HNHHEQVisualizer.h
//  HNHH
//
//  Created by Dobango on 9/17/13.
//  Copyright (c) 2013 RC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCSEQVisualizer : UIView

@property (nonatomic, strong) NSMutableArray *barArray;

- (id)initWithNumberOfBars:(int)number barWidth:(float)width height:(float)height color:(UInt32)hexColor;

- (void)startEq;
- (void)stopEq:(BOOL)animated;

@end

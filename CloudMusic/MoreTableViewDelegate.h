//
//  MoreTableViewDelegate.h
//  CloudMusic
//
//  Created by TuanTN on 3/15/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MoreTableViewDelegate : NSObject <UITableViewDelegate>

- (instancetype)initWithForwardingDelegate:(id<UITableViewDelegate>)delegate;

@end

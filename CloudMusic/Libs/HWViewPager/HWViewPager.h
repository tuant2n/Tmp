//
//  HWViewPager.h
//  AutoLayoutTest2
//
//  Created by HyunWoo Kim on 2015. 1. 8..
//  Copyright (c) 2015년 HyunWoo Kim. All rights reserved.
//



#import <UIKit/UIKit.h>

@protocol HWViewPagerDelegate <NSObject>

- (void)pagerDidSelectedPage:(NSInteger)selectedPage;

@optional

- (void)startScroll;
- (void)endScroll;

@end

@interface  HWViewPager : UICollectionView

- (void)setPagerDelegate:(id<HWViewPagerDelegate>)pagerDelegate;
- (void)setPage:(NSInteger)page isAnimation:(BOOL)isAnim isNotify:(BOOL)isNotify;

@end


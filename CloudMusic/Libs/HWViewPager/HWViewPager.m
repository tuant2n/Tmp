//
//  HWViewPager.m
//
//  Created by HyunWoo Kim on 2015. 1. 8..
//  Copyright (c) 2015년 HyunWoo Kim. All rights reserved.
//
//  email : hyunwoo-21@hanmail.net
//


/*
 @require 1. Need UICollectionViewFlowLayout
 @require 2. Don't Use SectionView
 @require 3. Initialize by Storyboard or initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
 
 
 제약 1. - 스토리보드를 사용해서 flowLayout을 사용할것.
 제약 2. 섹션 뷰는 사용하지 말것.
 제약 3. 스토리보드 씁시다.
 
 
 Usage 1 ... Configure FlowLayout's Section Inset (0, 0, 0, 0) AND minimumLineSpacing = 0 ... For Full Layout;
 
    but, for preview leftView and rightView -- set Section Inset value left, right and minimumLineSpaceing ...
 
 Usage 2... Use PageSelectedDelegate -  "setPagerDelgate" Method or storyboard outlet connection;
 
 사용 1. 풀스크린으로 사용하고싶다면 스토리보드에서 Section Inset 의 크기와 minLinespacing 모두 0으로 설정, 좌우 짤리는 모습쓰고 싶으면, 섹션 인셋의 left, right 와 minLinespacing 설정할것.
 사용 2. "setPagerDelegate" 메소드를 사용하거나, 스토리보드에서 아울렛을 연결하면, 페이지 선택 델리게이트를 사용할 수 있음.
 
 */

#import "HWViewPager.h"

#define VELOCITY_STANDARD 0.6f

@interface HWViewPager() <UICollectionViewDelegate>

typedef NS_ENUM(NSInteger, PagerControlState) {
    PagerControlStateStayCurrent,
    PagerControlStateMoveToLeft,
    PagerControlStateMoveToRight
};

@property (strong, nonatomic) UICollectionViewFlowLayout * flowLayout;
@property CGSize beforeSize;
@property NSInteger itemsTotalNum;
@property CGFloat itemWidthWithMargin;
@property NSInteger selectedPageNum;
@property CGFloat scrollBeginOffset;
@property enum PagerControlState pagerControlState;

@property (weak, nonatomic) IBOutlet id<HWViewPagerDelegate> userPagerDelegate;

@end

@implementation HWViewPager

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [self setScrollEnabled:YES];
    [self setPagingEnabled:NO];
    
    self.selectedPageNum = 0;
    self.flowLayout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
    
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self setDelegate:self];
    
    self.beforeSize = self.bounds.size;
    self.itemWidthWithMargin = self.bounds.size.width - (self.flowLayout.sectionInset.left + self.flowLayout.sectionInset.right);
    
    self.pagerControlState = PagerControlStateStayCurrent;
    [self setDecelerationRate: UIScrollViewDecelerationRateFast];
}

- (void)setPagerDelegate:(id<HWViewPagerDelegate>)pagerDelegate {
    self.userPagerDelegate = pagerDelegate;
}

#pragma mark - override...

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (!CGSizeEqualToSize(self.bounds.size, self.beforeSize))
    {
        CGFloat widthNew = self.bounds.size.width - (self.flowLayout.sectionInset.left + self.flowLayout.sectionInset.right + self.flowLayout.minimumLineSpacing);
        CGFloat heightNew = self.bounds.size.height - (self.flowLayout.sectionInset.top + self.flowLayout.sectionInset.bottom);
        self.flowLayout.itemSize = CGSizeMake(widthNew, heightNew);
        self.beforeSize = self.bounds.size;
        
        self.itemWidthWithMargin = widthNew + self.flowLayout.minimumLineSpacing;
        
        int targetX = [self getOffsetFromPage:self.selectedPageNum scrollView:self];
        [self setContentOffset:CGPointMake(targetX, 0)];
    }
}

- (void)reloadData
{
    [super reloadData];
    
    self.itemsTotalNum = 0;
    
    NSInteger sectionNum = [self numberOfSections];
    for (int i = 0; i < sectionNum; i++)
    {
        int numberOfItems = (int)[self.dataSource collectionView:self numberOfItemsInSection:i];
        self.itemsTotalNum += numberOfItems;
    }
    
    if (self.itemsTotalNum <= 1) {
        [self setScrollEnabled:NO];
    }
    else {
        [self setScrollEnabled:YES];
    }

    if (self.selectedPageNum <= 0) {
        self.selectedPageNum = 0;
    }
    int targetX = [self getOffsetFromPage:self.selectedPageNum scrollView:self];
    [self setContentOffset:CGPointMake(targetX, 0)];
}

- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths
{
    [super insertItemsAtIndexPaths:indexPaths];
    
    self.itemsTotalNum += indexPaths.count;
}

- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths
{
    [super deleteItemsAtIndexPaths:indexPaths];
    
    self.itemsTotalNum -= indexPaths.count;
    
    if (self.selectedPageNum >= self.itemsTotalNum - 1) {
        self.selectedPageNum = self.itemsTotalNum - 1;
    }
    int targetX = [self getOffsetFromPage:self.selectedPageNum scrollView:self];
    [self setContentOffset:CGPointMake(targetX, 0)];
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.scrollBeginOffset = scrollView.contentOffset.x;
    self.pagerControlState = PagerControlStateStayCurrent;
    
    if ([self.userPagerDelegate respondsToSelector:@selector(startScroll)]) {
        [self.userPagerDelegate startScroll];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint point = *targetContentOffset;

    if(velocity.x > VELOCITY_STANDARD){
        self.pagerControlState = PagerControlStateMoveToRight;
    }
    else if(velocity.x < -VELOCITY_STANDARD){
        self.pagerControlState = PagerControlStateMoveToLeft;
    }
    
    CGFloat scrolledDistance = self.scrollBeginOffset - scrollView.contentOffset.x;
    CGFloat standardDistance = self.itemWidthWithMargin/2;
    
    if (scrolledDistance < -standardDistance){
        self.pagerControlState = PagerControlStateMoveToRight;
        
    }
    else if (scrolledDistance > standardDistance){
        self.pagerControlState = PagerControlStateMoveToLeft;
    }
    
    if (self.pagerControlState == PagerControlStateMoveToLeft && self.selectedPageNum > 0) {
        self.selectedPageNum--;
    }
    else if (self.pagerControlState == PagerControlStateMoveToRight && self.selectedPageNum < self.itemsTotalNum - 1) {
        self.selectedPageNum++;
    }
    
    point.x = [self getOffsetFromPage:self.selectedPageNum scrollView:scrollView];
    *targetContentOffset = point;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.userPagerDelegate respondsToSelector:@selector(endScroll)]) {
        [self.userPagerDelegate endScroll];
    }
    
    if ([self.userPagerDelegate respondsToSelector:@selector(pagerDidSelectedPage:)]) {
        [self.userPagerDelegate pagerDidSelectedPage:self.selectedPageNum];
    }
}

- (CGFloat)getOffsetFromPage:(NSInteger)pageNum scrollView:(UIScrollView*)scrollView
{
    return (self.itemWidthWithMargin*pageNum) - (self.flowLayout.minimumLineSpacing/2);
}

- (void)setPage:(NSInteger)page isAnimation:(BOOL)isAnim isNotify:(BOOL)isNotify
{
    if (page == self.selectedPageNum || page >= self.itemsTotalNum) {
        return;
    }
    
    CGFloat offset = [self getOffsetFromPage:page scrollView:self];
    [self setContentOffset:CGPointMake(offset, 0) animated:isAnim];
    self.selectedPageNum = page;
    
    if (isNotify) {
        if ([self.userPagerDelegate respondsToSelector:@selector(pagerDidSelectedPage:)]) {
            [self.userPagerDelegate pagerDidSelectedPage:page];
        }
    }
}

@end

//
//  AlbumsViewController.m
//  CloudMusic
//
//  Created by TuanTN on 3/6/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "AlbumsViewController.h"

#import "Utils.h"
#import "GlobalParameter.h"
#import "DataManagement.h"

#import "AlbumsCell.h"

@interface AlbumsViewController () <MGSwipeTableCellDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
{
    BOOL isActiveSearch;
}

@property (nonatomic, strong) PCSEQVisualizer *musicEq;
@property (nonatomic, strong) UIBarButtonItem *barMusicEq;

@property (nonatomic, strong) NSMutableArray *albumsArray;

@property (nonatomic, weak) IBOutlet UITableView *tblList;
@property (nonatomic, weak) IBOutlet UITableView *tblSearchResult;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *keyboardLayout;
@property (nonatomic, weak) IBOutlet UIView *disableView;

@property (nonatomic, strong) TableFooterView *footerView;
@property (nonatomic, strong) TableHeaderView *headerView;

@end

@implementation AlbumsViewController

- (NSMutableArray *)albumsArray
{
    if (!_albumsArray) {
        _albumsArray = [[NSMutableArray alloc] init];
    }
    return _albumsArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self getData];
}

- (void)getData
{
    [self.albumsArray removeAllObjects];
    [self.albumsArray addObjectsFromArray:[[DataManagement sharedInstance] getListAlbumFilterByName:nil]];;
    [self.tblList reloadData];
    [self setupFooterView];
}

- (void)setupUI
{
    self.title = @"Albums";
    self.navigationItem.rightBarButtonItem = self.barMusicEq;
    
    self.disableView.backgroundColor = [UIColor blackColor];
    self.disableView.alpha = 0.0;
    self.disableView.hidden = YES;
    [self.disableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSearch)]];
    
    self.tblList.sectionIndexColor = [Utils colorWithRGBHex:0x006bd5];
    self.tblList.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tblList.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    
    [self.tblList registerNib:[UINib nibWithNibName:@"AlbumsCell" bundle:nil] forCellReuseIdentifier:@"AlbumsCellId"];

    [self.tblSearchResult registerNib:[UINib nibWithNibName:@"SongsCell" bundle:nil] forCellReuseIdentifier:@"SongsCellId"];
    [self.tblSearchResult registerNib:[UINib nibWithNibName:@"SongHeaderTitle" bundle:nil] forCellReuseIdentifier:@"SongHeaderTitleId"];
    
    [self setupHeaderBar];
    [self.tblList setTableFooterView:self.footerView];
}

- (void)setupHeaderBar
{
    [self.headerView setupForSongsVC];
    self.headerView.searchBar.delegate = self;
    
    self.keyboardLayout.priority = 750;
    self.tblSearchResult.tableFooterView = nil;
    
    [self.tblList setTableHeaderView:self.headerView];
}

#pragma mark - UISearchBarDelegate

- (void)closeSearch
{
    [self searchBar:self.headerView.searchBar activate:NO];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self searchBar:searchBar activate:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = nil;
    [self searchBar:searchBar activate:NO];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL)isActive
{
    isActiveSearch = isActive;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.headerView setActiveSearchBar:isActiveSearch];
        [self.tblList setTableHeaderView:self.headerView];
    } completion:nil];
    
    self.tblList.allowsSelection = !isActiveSearch;
    self.tblList.scrollEnabled = !isActiveSearch;
    
    if (isActiveSearch) {
        [self showOverlayDisable:YES];
        
        self.tblSearchResult.delegate = self;
        self.tblSearchResult.dataSource = self;
    }
    else {
        [self showOverlayDisable:NO];
        [searchBar resignFirstResponder];
        
        self.tblSearchResult.delegate = nil;
        self.tblSearchResult.dataSource = nil;
    }
    
    [self.tblList reloadSectionIndexTitles];
    [searchBar setShowsCancelButton:isActiveSearch animated:YES];
}

- (void)subscribeToKeyboard {
    [self an_subscribeKeyboardWithAnimations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {
        if (isShowing) {
            self.keyboardLayout.constant = CGRectGetHeight(keyboardRect);
        } else {
            self.keyboardLayout.constant = [[[self tabBarController] tabBar] bounds].size.height;
        }
        [self.tblSearchResult layoutIfNeeded];
    } completion:nil];
}

- (void)showOverlayDisable:(BOOL)isShow
{
    if (isShow) {
        self.disableView.hidden = NO;
        self.tblSearchResult.alpha = 0.0;
        self.tblSearchResult.hidden = NO;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.disableView.alpha = 0.5;
        } completion:nil];
    }
    else {
        self.disableView.alpha = 0.0;
        self.disableView.hidden = YES;
        self.tblSearchResult.hidden = YES;
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0) {
        self.disableView.hidden = YES;
        self.tblSearchResult.alpha = 1.0;
        self.tblSearchResult.hidden = NO;
    }
    else {
        self.disableView.hidden = NO;
        self.tblSearchResult.alpha = 0.0;
        self.tblSearchResult.hidden = YES;
    }
    
    [self.tblSearchResult reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblSearchResult) {
        return 0;
    }
    else {
        return self.albumsArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [AlbumsCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumsCell *cell = (AlbumsCell *)[tableView dequeueReusableCellWithIdentifier:@"AlbumsCellId" forIndexPath:indexPath];
    [cell setLineHidden:(indexPath.row == self.albumsArray.count - 1)];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(AlbumsCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    AlbumObj *album = self.albumsArray[indexPath.row];
    [cell config:album];
}

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    NSIndexPath *indexPath = [self.tblList indexPathForCell:cell];
    if (!indexPath) {
        return YES;
    }
    
    if (direction == MGSwipeDirectionLeftToRight)
    {
//        Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
//        
//        if (item.isCloud.boolValue && index == 0) {
//            return NO;
//        }
    }
    
    return YES;
}

#pragma mark - UI

- (TableFooterView *)footerView
{
    if (!_footerView) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TableFooterView" owner:self options:nil];
        if ([nib count] > 0) {
            _footerView = [nib objectAtIndex:0];
        }
    }
    return _footerView;
}

- (void)setupFooterView
{
    NSString *sContent = nil;
    int itemCount = (int)self.albumsArray.count;
    
    if (itemCount <= 1) {
        sContent = [NSString stringWithFormat:@"%d Album",itemCount];
    }
    else {
        sContent = [NSString stringWithFormat:@"%d Albums",itemCount];
    }
    
    [self.footerView setContent:sContent];
}

- (TableHeaderView *)headerView
{
    if (!_headerView) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TableHeaderView" owner:self options:nil];
        if ([nib count] > 0) {
            _headerView = [nib objectAtIndex:0];
        }
    }
    return _headerView;
}

- (void)hideHeaderView
{
    if (self.tblList.tableHeaderView) {
        self.tblList.contentOffset = CGPointMake(0.0, self.tblList.tableHeaderView.bounds.size.height);
    }
}

#pragma mark - MusicEq

- (PCSEQVisualizer *)musicEq
{
    if (!_musicEq) {
        _musicEq = [[PCSEQVisualizer alloc] initWithNumberOfBars:3 barWidth:2 height:18.0 color:0x006bd5];
    }
    return _musicEq;
}

- (UIBarButtonItem *)barMusicEq
{
    if (!_barMusicEq)
    {
        UIButton *btnEqHolder = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnEqHolder setFrame:CGRectMake(0.0, 0.0, 35.0, 35.0)];
        btnEqHolder.backgroundColor = [UIColor clearColor];
        [btnEqHolder addTarget:self action:@selector(openPlayer:) forControlEvents:UIControlEventTouchUpInside];
        btnEqHolder.multipleTouchEnabled = NO;
        btnEqHolder.exclusiveTouch = YES;
        
        CGRect frame = self.musicEq.frame;
        frame.origin.x = (btnEqHolder.frame.size.width - frame.size.width);
        frame.origin.y = (btnEqHolder.frame.size.height - frame.size.height) / 2.0;
        self.musicEq.frame = frame;
        [btnEqHolder addSubview:self.musicEq];
        
        _barMusicEq = [[UIBarButtonItem alloc] initWithCustomView:btnEqHolder];
    }
    return _barMusicEq;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self an_unsubscribeKeyboard];
    [self searchBar:self.headerView.searchBar activate:NO];
    [self.musicEq stopEq:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self subscribeToKeyboard];
    [self hideHeaderView];
    
    if ([[GlobalParameter sharedInstance] isPlay]) {
        [self.musicEq startEq];
    }
    else {
        [self.musicEq stopEq:NO];
    }
}

- (void)dealloc {
    [self an_unsubscribeKeyboard];
}

#pragma mark - Method

- (void)openPlayer:(id)sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

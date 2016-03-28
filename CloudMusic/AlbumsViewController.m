//
//  AlbumsViewController.m
//  CloudMusic
//
//  Created by TuanTN on 3/6/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "AlbumsViewController.h"

#import "SongsViewController.h"

#import "Utils.h"
#import "GlobalParameter.h"
#import "DataManagement.h"

@interface AlbumsViewController () <MGSwipeTableCellDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,TableHeaderViewDelegate>
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

@property (nonatomic, strong) NSMutableArray *arrResults;
@property (nonatomic, strong) TableFooterView *footerView;
@property (nonatomic, strong) TableHeaderView *headerView;

@end

@implementation AlbumsViewController

- (NSMutableArray *)arrResults
{
    if (!_arrResults) {
        _arrResults = [[NSMutableArray alloc] init];
    }
    return _arrResults;
}

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
    [self.albumsArray addObjectsFromArray:[[DataManagement sharedInstance] getListAlbumFilterByName:nil artistId:self.iAlbumArtistId genreId:self.iGenreId]];
    [self.tblList reloadData];
    [self setupFooterView];
}

- (void)setupUI
{
    if (self.sTitle) {
        self.title = self.sTitle;
    }
    else {
        self.title = @"Albums";
    }
    self.navigationItem.rightBarButtonItem = self.barMusicEq;
    
    self.disableView.backgroundColor = [UIColor blackColor];
    self.disableView.alpha = 0.0;
    self.disableView.hidden = YES;
    [self.disableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSearch)]];
    
    self.tblList.sectionIndexColor = [Utils colorWithRGBHex:0x006bd5];
    self.tblList.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tblList.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    
    [Utils registerNibForTableView:self.tblList];
    [Utils registerNibForTableView:self.tblSearchResult];
    
//    [self setupHeaderBar];
    [self.tblList setTableFooterView:self.footerView];
}

- (void)setupHeaderBar
{
    [self.headerView setupForAlbumVC];
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
         [self.arrResults removeAllObjects];
        [self showOverlayDisable:YES];
        
        self.tblSearchResult.delegate = self;
        self.tblSearchResult.dataSource = self;
    }
    else {
         [self.arrResults removeAllObjects];
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

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *searchString = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    if (searchString.length > 0)
    {
        [self doSearch:searchString];
    }
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self doSearch:searchBar.text];
}

- (void)doSearch:(NSString *)sSearch
{
    [self.arrResults removeAllObjects];
    
    [[DataManagement sharedInstance] search:sSearch block:^(NSArray *results)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (results) {
                 [self.arrResults addObjectsFromArray:results];
             }
             [UIView transitionWithView:self.tblSearchResult duration:0.35f options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionCurveEaseInOut animations:^{
                 [self.tblSearchResult reloadData];
             } completion:nil];
         });
     }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tblSearchResult) {
        return self.arrResults.count;
    }
    else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblSearchResult) {
        return self.arrResults.count;
    }
    else {
        return self.albumsArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tblSearchResult) {
        return [Utils normalCellHeight];
    }
    else {
        return [AlbumsCell height];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tblSearchResult) {
        return [HeaderTitle height];
    }
    else {
        return 0.0;;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sTitle = nil;
    
    if (tableView == self.tblSearchResult) {
        SearchResultObj *resultOj = self.arrResults[section];
        sTitle = resultOj.sTitle;
    }

    HeaderTitle *header = (HeaderTitle *)[tableView dequeueReusableCellWithIdentifier:@"HeaderTitleId"];
    [header setTitle:sTitle];
    return header.contentView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tblSearchResult) {
        SearchResultObj *resultOj = self.arrResults[indexPath.section];
        id itemObj = resultOj.resuls[indexPath.row];
        return [self configCellWithItem:itemObj atIndex:indexPath tableView:tableView];
    }
    else {
        AlbumsCell *cell = (AlbumsCell *)[tableView dequeueReusableCellWithIdentifier:@"AlbumsCellId" forIndexPath:indexPath];
        [cell setLineHidden:(indexPath.row == self.albumsArray.count - 1)];
        
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }
}

- (void)configureCell:(AlbumsCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    AlbumObj *album = self.albumsArray[indexPath.row];
    [cell config:album];
}

- (UITableViewCell *)configCellWithItem:(id)itemObj atIndex:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    if ([itemObj isKindOfClass:[Item class]]) {
        SongsCell *cell = (SongsCell *)[tableView dequeueReusableCellWithIdentifier:@"SongsCellId" forIndexPath:indexPath];
        [cell configWithItem:itemObj];
        return cell;
    }
    else if ([itemObj isKindOfClass:[AlbumObj class]]) {
        AlbumsCell *cell = (AlbumsCell *)[tableView dequeueReusableCellWithIdentifier:@"AlbumsCellId" forIndexPath:indexPath];
        [cell config:itemObj];
        return cell;
    }
    else if ([itemObj isKindOfClass:[AlbumArtistObj class]]) {
        ArtistsCell *cell = (ArtistsCell *)[tableView dequeueReusableCellWithIdentifier:@"ArtistsCellId" forIndexPath:indexPath];
        [cell config:itemObj];
        return cell;
    }
    else if ([itemObj isKindOfClass:[GenresObj class]]) {
        GenresCell *cell = (GenresCell *)[tableView dequeueReusableCellWithIdentifier:@"GenresCellId" forIndexPath:indexPath];
        [cell config:itemObj];
        return cell;
    }
    
    return nil;
}

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    NSIndexPath *indexPath = [self.tblList indexPathForCell:cell];
    if (!indexPath) {
        return YES;
    }
    
    if (direction == MGSwipeDirectionLeftToRight)
    {
        AlbumObj *item = self.albumsArray[indexPath.row];
        
        if (item.isCloud && index == 0) {
            return NO;
        }
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
            _headerView.delegate = self;
        }
    }
    return _headerView;
}

- (void)selectUtility:(kHeaderUtilType)iType
{
    if (iType == kHeaderUtilTypeCreatePlaylist) {
        
    }
    else if (iType == kHeaderUtilTypeGoAllSongs)
    {
        
    }
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
    SongsViewController *vc = [[SongsViewController alloc] initWithNibName:@"SongsViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

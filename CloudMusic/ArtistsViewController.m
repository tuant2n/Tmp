//
//  ArtistsViewController.m
//  CloudMusic
//
//  Created by TuanTN on 3/13/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "ArtistsViewController.h"

#import "Utils.h"
#import "GlobalParameter.h"
#import "DataManagement.h"

@interface ArtistsViewController () <MGSwipeTableCellDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,TableHeaderViewDelegate>
{
    BOOL isActiveSearch;
    NSString *sCurrentSearch;
}

@property (nonatomic, strong) PCSEQVisualizer *musicEq;
@property (nonatomic, strong) UIBarButtonItem *barMusicEq;

@property (nonatomic, strong) NSMutableArray *artistArray;

@property (nonatomic, weak) IBOutlet UITableView *tblList;
@property (nonatomic, weak) IBOutlet UITableView *tblSearchResult;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *keyboardLayout;
@property (nonatomic, weak) IBOutlet UIView *disableView;

@property (nonatomic, strong) NSMutableArray *arrResults;
@property (nonatomic, strong) TableFooterView *footerView;
@property (nonatomic, strong) TableHeaderView *headerView;

@end

@implementation ArtistsViewController

- (NSMutableArray *)arrResults
{
    if (!_arrResults) {
        _arrResults = [[NSMutableArray alloc] init];
    }
    return _arrResults;
}

- (NSMutableArray *)artistArray
{
    if (!_artistArray) {
        _artistArray = [[NSMutableArray alloc] init];
    }
    return _artistArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self getData];
}

- (void)getData
{
    [self.artistArray removeAllObjects];
    [self.artistArray addObjectsFromArray:[[DataManagement sharedInstance] getListAlbumArtistFilterByName:nil]];
    [self.tblList reloadData];
    [self setupFooterView];
}

- (void)setupUI
{
    self.title = @"Artists";
    self.navigationItem.rightBarButtonItem = self.barMusicEq;
    [Utils configNavigationController:self.navigationController];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    self.disableView.backgroundColor = [UIColor blackColor];
    self.disableView.alpha = 0.0;
    self.disableView.hidden = YES;
    [self.disableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSearch)]];
    
    self.tblList.sectionIndexColor = [Utils colorWithRGBHex:0x006bd5];
    self.tblList.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tblList.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    
    [Utils registerNibForTableView:self.tblList];
    [Utils registerNibForTableView:self.tblSearchResult];
    
    [self setupHeaderBar];
    [self.tblList setTableFooterView:self.footerView];
}

- (void)setupHeaderBar
{
    self.headerView.searchBar.delegate = self;
    [self.tblList setTableHeaderView:self.headerView];
    
    self.keyboardLayout.priority = 750;
    self.tblSearchResult.tableFooterView = nil;
}

- (void)closeSearch
{
    [self searchBar:self.headerView.searchBar activate:NO];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self searchBar:searchBar activate:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self searchBar:searchBar activate:NO];
}

- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL)isActive
{
    [searchBar setShowsCancelButton:isActive animated:YES];
    
    if (isActiveSearch == isActive) {
        return;
    }
    
    isActiveSearch = isActive;
    
    [self.arrResults removeAllObjects];
    sCurrentSearch = nil;
    self.headerView.searchBar.text = sCurrentSearch;
    
    if (isActiveSearch)
    {
        [self showOverlayDisable:YES];
        
        self.tblSearchResult.delegate = self;
        self.tblSearchResult.dataSource = self;
    }
    else {
        [self showOverlayDisable:NO];
        
        if ([searchBar isFirstResponder]) {
            [searchBar resignFirstResponder];
        }
        
        self.tblSearchResult.delegate = nil;
        self.tblSearchResult.dataSource = nil;
    }
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [self.headerView setActiveSearchBar:isActiveSearch];
        [self.tblList setTableHeaderView:self.headerView];
    } completion:nil];
    
    self.tblList.allowsSelection = !isActiveSearch;
    self.tblList.scrollEnabled = !isActiveSearch;
    
    [self.tblList reloadSectionIndexTitles];
}

- (void)showOverlayDisable:(BOOL)isShow
{
    if (isShow)
    {
        self.disableView.hidden = NO;
        self.tblSearchResult.hidden = NO;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.disableView.alpha = 0.5;
            self.tblSearchResult.alpha = 0.0;
        } completion:nil];
    }
    else {
        self.disableView.hidden = YES;
        self.tblSearchResult.hidden = YES;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.disableView.alpha = 0.0;
            self.tblSearchResult.alpha = 0.0;
        } completion:nil];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self doSearch:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)doSearch:(NSString *)sSearch
{
    sSearch = [sSearch stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([sSearch isEqualToString:sCurrentSearch])
    {
        return;
    }
    
    [self.arrResults removeAllObjects];
    sCurrentSearch = sSearch;
    
    if (sCurrentSearch.length <= 0)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.disableView.hidden = NO;
            self.tblSearchResult.alpha = 0.0;
            [self.tblSearchResult reloadData];
        } completion:nil];
    }
    else {
        [[DataManagement sharedInstance] search:sCurrentSearch searchType:kSearchTypeArtist block:^(NSArray *results)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (results) {
                     [self.arrResults addObjectsFromArray:results];
                 }
                 
                 self.disableView.hidden = YES;
                 self.tblSearchResult.alpha = 1.0;
                 
                 [UIView transitionWithView:self.tblSearchResult duration:0.3f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                     [self.tblSearchResult reloadData];
                 } completion:nil];
             });
         }];
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tblSearchResult) {
        return [HeaderTitle height];
    }
    else {
        return 0.0;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblSearchResult) {
        SearchResultObj *resultOj = self.arrResults[section];
        return resultOj.resuls.count;
    }
    else {
        return self.artistArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MainCell normalCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainCell *cell = nil;
    id cellItem = nil;
    BOOL isHiddenSeperator = NO;
    
    if (tableView == self.tblSearchResult) {
        SearchResultObj *resultObj = self.arrResults[indexPath.section];
        cellItem = resultObj.resuls[indexPath.row];
        isHiddenSeperator = (indexPath.row == [resultObj.resuls count] - 1);
    }
    else {
        cellItem = self.artistArray[indexPath.row];
        isHiddenSeperator = (indexPath.row == [self.artistArray count] - 1);
    }
    
    cell = [self configCellWithItem:cellItem atIndex:indexPath tableView:tableView];
    
    if (cell && cellItem)
    {
        cell.delegate = self;
        cell.allowsMultipleSwipe = NO;
        
        [cell config:cellItem];
        [cell setLineHidden:isHiddenSeperator];
    }
    
    return cell;
}

- (MainCell *)configCellWithItem:(id)itemObj atIndex:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    MainCell *cell = nil;
    
    if ([itemObj isKindOfClass:[Item class]]) {
        cell = (SongsCell *)[tableView dequeueReusableCellWithIdentifier:@"SongsCellId" forIndexPath:indexPath];
    }
    else if ([itemObj isKindOfClass:[AlbumObj class]]) {
        cell = (AlbumsCell *)[tableView dequeueReusableCellWithIdentifier:@"AlbumsCellId" forIndexPath:indexPath];
    }
    else if ([itemObj isKindOfClass:[AlbumArtistObj class]]) {
        cell = (ArtistsCell *)[tableView dequeueReusableCellWithIdentifier:@"ArtistsCellId" forIndexPath:indexPath];
    }
    else if ([itemObj isKindOfClass:[GenreObj class]]) {
        cell = (GenresCell *)[tableView dequeueReusableCellWithIdentifier:@"GenresCellId" forIndexPath:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id itemObj = nil;
    
    if (tableView == self.tblSearchResult) {
        SearchResultObj *resultOj = self.arrResults[indexPath.section];
        itemObj = resultOj.resuls[indexPath.row];
    }
    else {
        itemObj = [self.artistArray objectAtIndex:indexPath.row];
    }
    
    if (itemObj) {
        [self.headerView resignKeyboard];
        [self doActionWithItem:itemObj];
    }
}

- (void)doActionWithItem:(id)item
{
    if ([item isKindOfClass:[Item class]]) {
        [[GlobalParameter sharedInstance] setCurrentItemPlay:(Item *)item];
    }
    else if ([item isKindOfClass:[AlbumObj class]]) {

    }
    else if ([item isKindOfClass:[AlbumArtistObj class]]) {
        AlbumArtistObj *artist = (AlbumArtistObj *)item;
        
        AlbumsViewController *vc = [[AlbumsViewController alloc] init];
        vc.sTitle = artist.sAlbumArtistName;
        vc.iAlbumArtistId = artist.iAlbumArtistId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([item isKindOfClass:[GenreObj class]]) {
        GenreObj *genre = (GenreObj *)item;
        
        AlbumsViewController *vc = [[AlbumsViewController alloc] init];
        vc.sTitle = genre.sGenreName;
        vc.iGenreId = genre.iGenreId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    NSIndexPath *indexPath = [self.tblList indexPathForCell:cell];
    if (!indexPath) {
        return YES;
    }
    
    if (direction == MGSwipeDirectionLeftToRight)
    {
        AlbumObj *item = self.artistArray[indexPath.row];
        
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
    int itemCount = (int)self.artistArray.count;
    
    if (itemCount <= 1) {
        sContent = [NSString stringWithFormat:@"%d Artist",itemCount];
    }
    else {
        sContent = [NSString stringWithFormat:@"%d Artists",itemCount];
    }
    
    [self.footerView setContent:sContent];
}

- (TableHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = [[TableHeaderView alloc] initForArtistsVC];
        _headerView.delegate = self;
    }
    return _headerView;
}

- (void)selectUtility:(kHeaderUtilType)iType
{
    if (iType == kHeaderUtilTypeCreatePlaylist) {
        
    }
    else if (iType == kHeaderUtilTypeGoAllAlbums) {
        AlbumsViewController *vc = [[AlbumsViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)hideHeaderView
{
    if (isActiveSearch) {
        return;
    }
    
    if (self.tblList.tableHeaderView) {
        self.tblList.contentOffset = CGPointMake(0.0, [self.headerView getHeight]);
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
        _barMusicEq = [[UIBarButtonItem alloc] initWithCustomView:[Utils buttonMusicEqualizeqHolderWith:self.musicEq target:self action:@selector(openPlayer:)]];
    }
    return _barMusicEq;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.musicEq stopEq:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self hideHeaderView];
    
    if ([[GlobalParameter sharedInstance] isPlay]) {
        [self.musicEq startEq];
    }
    else {
        [self.musicEq stopEq:NO];
    }
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

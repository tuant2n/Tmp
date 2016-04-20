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

@property (nonatomic, strong) NSMutableArray *arrData;

@property (nonatomic, weak) IBOutlet UITableView *tblList;
@property (nonatomic, weak) IBOutlet UITableView *tblSearchResult;
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

- (NSMutableArray *)arrData
{
    if (!_arrData) {
        _arrData = [[NSMutableArray alloc] init];
    }
    return _arrData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self getData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:NOTIFICATION_RELOAD_DATA object:nil];
}

- (void)getData
{
    [self.arrData removeAllObjects];
    [self.arrData addObjectsFromArray:[[DataManagement sharedInstance] getListAlbumArtistFilterByName:nil]];
    [self.tblList reloadData];
    [self setupFooterView];
}

- (void)reloadData:(NSNotification *)notification
{
    if (isActiveSearch) {
        [self searchBar:self.headerView.searchBar activate:NO];
    }
    
    [self getData];
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
    
    [Utils configTableView:self.tblList isSearch:NO];
    [Utils configTableView:self.tblSearchResult isSearch:YES];
    
    [self setupHeaderBar];
    [self.tblList setTableFooterView:self.footerView];
}

- (void)setupHeaderBar
{
    self.headerView.searchBar.delegate = self;
    [self.tblList setTableHeaderView:self.headerView];
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
        DataObj *resultOj = self.arrResults[section];
        sTitle = resultOj.sTitle;
    }
    
    HeaderTitle *header = (HeaderTitle *)[tableView dequeueReusableCellWithIdentifier:@"HeaderTitleId"];
    [header setTitle:sTitle];
    return header.contentView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblSearchResult) {
        DataObj *resultOj = self.arrResults[section];
        return resultOj.listData.count;
    }
    else {
        return self.arrData.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MainCell normalCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cellItem = nil;
    
    if (tableView == self.tblSearchResult) {
        DataObj *resultObj = self.arrResults[indexPath.section];
        cellItem = resultObj.listData[indexPath.row];
    }
    else {
        cellItem = self.arrData[indexPath.row];
    }
    
    return [Utils getCellWithItem:cellItem atIndex:indexPath tableView:tableView];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[MainCell class]])
    {
        id cellItem = nil;
        BOOL isHiddenSeperator = NO;
        
        if (tableView == self.tblSearchResult) {
            DataObj *resultObj = self.arrResults[indexPath.section];
            cellItem = resultObj.listData[indexPath.row];
            isHiddenSeperator = (indexPath.row == [resultObj.listData count] - 1);
        }
        else {
            cellItem = self.arrData[indexPath.row];
            isHiddenSeperator = (indexPath.row == [self.arrData count] - 1);
        }
        
        MainCell *mainCell = (MainCell *)cell;
        mainCell.delegate = self;
        mainCell.allowsMultipleSwipe = NO;
        
        [mainCell config:cellItem];
        [mainCell setLineHidden:isHiddenSeperator];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id itemObj = nil;
    
    if (tableView == self.tblSearchResult) {
        DataObj *resultOj = self.arrResults[indexPath.section];
        itemObj = resultOj.listData[indexPath.row];
    }
    else {
        itemObj = [self.arrData objectAtIndex:indexPath.row];
    }
    
    if (itemObj) {
        [self.headerView resignKeyboard];
        [[DataManagement sharedInstance] doActionWithItem:itemObj withData:nil fromSearch:isActiveSearch fromNavigation:self.navigationController];
    }
}

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    id itemObj = nil;
    
    if (isActiveSearch) {
        NSIndexPath *indexPath = [self.tblSearchResult indexPathForCell:cell];
        DataObj *resultOj = self.arrResults[indexPath.section];
        itemObj = resultOj.listData[indexPath.row];
    }
    else {
        NSIndexPath *indexPath = [self.tblList indexPathForCell:cell];
        itemObj = self.arrData[indexPath.row];
    }
    
    if (!itemObj) {
        return YES;
    }
    
    if (direction == MGSwipeDirectionLeftToRight)
    {
        return [[DataManagement sharedInstance] doSwipeActionWithItem:itemObj atIndex:index fromNavigation:self.navigationController];
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
    int itemCount = (int)self.arrData.count;
    
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
    [[DataManagement sharedInstance] doUtility:iType withData:self.arrData fromNavigation:self.navigationController];
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

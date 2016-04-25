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

@interface ArtistsViewController () <MGSwipeTableCellDelegate,UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource,TableHeaderViewDelegate>
{
    NSString *sCurrentSearch;
}

@property (nonatomic, strong) PCSEQVisualizer *musicEq;
@property (nonatomic, strong) UIBarButtonItem *barMusicEq;

@property (nonatomic, strong) NSMutableArray *arrData;

@property (nonatomic, weak) IBOutlet UITableView *tblList;
@property (nonatomic, strong) UISearchDisplayController *searchDisplay;

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
    if ([self.searchDisplay isActive]) {
        [self.searchDisplay setActive:NO animated:NO];
    }
    
    [self getData];
}

- (void)setupUI
{
    self.title = @"Artists";
    self.navigationItem.rightBarButtonItem = self.barMusicEq;
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    [Utils configTableView:self.tblList];
    [self setupHeaderBar];
    [self.tblList setTableFooterView:self.footerView];
}

- (void)setupHeaderBar
{
    [self.tblList setTableHeaderView:self.headerView];
    
    self.searchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:self.headerView.searchBar contentsController:self];
    self.searchDisplay.searchResultsDataSource = self;
    self.searchDisplay.searchResultsDelegate = self;
    self.searchDisplay.delegate = self;
}

- (UINavigationController *)navigationController
{
    return nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView != self.tblList) {
        return self.arrResults.count;
    }
    else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView != self.tblList) {
        return [HeaderTitle height];
    }
    else {
        return 0.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sTitle = nil;
    
    if (tableView != self.tblList) {
        DataObj *resultOj = self.arrResults[section];
        sTitle = resultOj.sTitle;
    }
    
    HeaderTitle *header = (HeaderTitle *)[tableView dequeueReusableCellWithIdentifier:@"HeaderTitleId"];
    [header setTitle:sTitle];
    return header.contentView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != self.tblList) {
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
    
    if (tableView != self.tblList) {
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
        
        MainCell *mainCell = (MainCell *)cell;
        mainCell.delegate = self;
        mainCell.allowsMultipleSwipe = NO;
        
        if (tableView != self.tblList) {
            DataObj *resultObj = self.arrResults[indexPath.section];
            cellItem = resultObj.listData[indexPath.row];
            
            [mainCell configWithoutMenu:cellItem];
            [mainCell setLineHidden:(indexPath.row == [resultObj.listData count] - 1)];
        }
        else {
            cellItem = self.arrData[indexPath.row];
            
            [mainCell config:cellItem];
            [mainCell setLineHidden:(indexPath.row == [self.arrData count] - 1)];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id itemObj = nil;
    
    if (tableView != self.tblList) {
        DataObj *resultOj = self.arrResults[indexPath.section];
        itemObj = resultOj.listData[indexPath.row];
    }
    else {
        itemObj = [self.arrData objectAtIndex:indexPath.row];
    }
    
    if (itemObj) {
        [[DataManagement sharedInstance] doActionWithItem:itemObj withData:nil fromSearch:(tableView != self.tblList) fromNavigation:[super navigationController]];
    }
}

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    NSIndexPath *indexPath = [self.tblList indexPathForCell:cell];
    id itemObj = self.arrData[indexPath.row];
    
    return [[DataManagement sharedInstance] doSwipeActionWithItem:itemObj atIndex:index isLeftAction:(direction == MGSwipeDirectionLeftToRight) fromNavigation:[super navigationController]];
}

#pragma mark - UISearchDisplayControllerDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [tableView setContentInset:UIEdgeInsetsMake(SEARCHBAR_HEIGHT, 0.0, 0.0, 0.0)];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsMake(SEARCHBAR_HEIGHT, 0.0, 0.0, 0.0)];
    [tableView setTableFooterView:[Utils tableLine]];
    [tableView setTableFooterView:[Utils tableLine]];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    [Utils findAndHideSearchBarShadowInView:tableView];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
    [self closeSearch];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    controller.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [Utils registerXibs:controller.searchResultsTableView];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self closeSearch];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (!searchString || [searchString isEqualToString:sCurrentSearch]) {
        return NO;
    }
    
    searchString = [Utils standardLocaleString:searchString];
    sCurrentSearch = searchString;
    
    [[DataManagement sharedInstance] search:sCurrentSearch searchType:kSearchTypeArtist block:^(NSArray *results)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (results) {
                 [self.arrResults removeAllObjects];
                 [self.arrResults addObjectsFromArray:results];
                 
                 [UIView transitionWithView:self.searchDisplayController.searchResultsTableView duration:0.3f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                     [self.searchDisplayController.searchResultsTableView reloadData];
                 } completion:nil];
             }
         });
     }];
    
    return YES;
}

- (void)closeSearch
{
    if ([self.searchDisplay isActive]) {
        [self.searchDisplay setActive:NO animated:NO];
    }
    
    sCurrentSearch = nil;
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
    [[DataManagement sharedInstance] doUtility:iType withData:self.arrData fromNavigation:[super navigationController]];
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

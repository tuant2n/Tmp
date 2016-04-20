//
//  PlaylistsViewController.m
//  CloudMusic
//
//  Created by TuanTN on 3/6/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "PlaylistsViewController.h"

#import "Utils.h"
#import "GlobalParameter.h"
#import "DataManagement.h"

@interface PlaylistsViewController () <NSFetchedResultsControllerDelegate,MGSwipeTableCellDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,TableHeaderViewDelegate>
{
    BOOL isActiveSearch;
    NSString *sCurrentSearch;
}

@property (nonatomic, strong) PCSEQVisualizer *musicEq;
@property (nonatomic, strong) UIBarButtonItem *barMusicEq;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, weak) IBOutlet UITableView *tblList;
@property (nonatomic, weak) IBOutlet UITableView *tblSearchResult;
@property (nonatomic, weak) IBOutlet UIView *disableView;

@property (nonatomic, strong) NSMutableArray *arrResults;
@property (nonatomic, strong) TableHeaderView *headerView;

@end

@implementation PlaylistsViewController

- (NSMutableArray *)arrResults
{
    if (!_arrResults) {
        _arrResults = [[NSMutableArray alloc] init];
    }
    return _arrResults;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController)
    {
        NSFetchRequest *request = [[DataManagement sharedInstance] getListPlaylistIsGetNormalOnly:NO];
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[DataManagement sharedInstance] managedObjectContext] sectionNameKeyPath:@"isSmartPlaylist" cacheName:nil];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    [self performFetch];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:NOTIFICATION_RELOAD_DATA object:nil];
}

- (void)performFetch
{
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Fetch error: %@", error);
    }
    else {
        [self.tblList reloadData];
    }
}

- (void)setupUI
{
    self.title = @"Playlist";
    self.navigationItem.rightBarButtonItem = self.barMusicEq;
    [Utils configNavigationController:self.navigationController];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    self.disableView.backgroundColor = [UIColor blackColor];
    self.disableView.alpha = 0.0;
    self.disableView.hidden = YES;
    [self.disableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSearch)]];
    
    [Utils configTableView:self.tblList isSearch:YES];
    [Utils configTableView:self.tblSearchResult isSearch:YES];
    
    [self setupHeaderBar];
}

- (void)reloadData:(NSNotification *)notification
{
    if (isActiveSearch) {
        [self searchBar:self.headerView.searchBar activate:NO];
    }
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

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if(index == 0) [tableView scrollRectToVisible:tableView.tableHeaderView.frame animated: NO];
    return (index - 1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tblSearchResult) {
        return self.arrResults.count;
    }
    else {
        return [[self.fetchedResultsController sections] count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [HeaderTitle height];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sTitle = nil;
    
    if (tableView == self.tblSearchResult) {
        DataObj *resultOj = self.arrResults[section];
        sTitle = resultOj.sTitle;
    }
    else {
        sTitle = [self tableView:tableView titleForHeaderInSection:section];
    }
    
    HeaderTitle *header = (HeaderTitle *)[tableView dequeueReusableCellWithIdentifier:@"HeaderTitleId"];
    [header setTitle:sTitle];
    return header.contentView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Smart playlists";
    }
    else {
        return @"Playlists";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblSearchResult) {
        DataObj *resultOj = self.arrResults[section];
        return resultOj.listData.count;
    }
    else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        return [sectionInfo numberOfObjects];
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
        DataObj *resultOj = self.arrResults[indexPath.section];
        cellItem = resultOj.listData[indexPath.row];
    }
    else {
        cellItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
            DataObj *resultOj = self.arrResults[indexPath.section];
            cellItem = resultOj.listData[indexPath.row];
            isHiddenSeperator = (indexPath.row == [resultOj.listData count] - 1);
        }
        else {
            id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][indexPath.section];
            cellItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
            isHiddenSeperator = (indexPath.row == [sectionInfo numberOfObjects] - 1);
        }
        
        MainCell *mainCell = (MainCell *)cell;
        mainCell.delegate = self;
        mainCell.allowsMultipleSwipe = NO;
        
        [mainCell config:cellItem];
        [mainCell setLineHidden:isHiddenSeperator];
    }
}

- (void)configureCell:(MainCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell config:item];
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
        itemObj = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
        itemObj = [self.fetchedResultsController objectAtIndexPath:indexPath];
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

#pragma mark - Fetched Results Controller Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (isActiveSearch) {
        [self searchBar:self.headerView.searchBar activate:NO];
    }
    
    [self.tblList beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert: {
            [self.tblList insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            
            break;
            
        case NSFetchedResultsChangeDelete: {
            [self.tblList deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            
            break;
            
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:(SongsCell *)[self.tblList cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
        }
            break;
            
        case NSFetchedResultsChangeMove: {
            [self.tblList deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tblList insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert: {
            [self.tblList insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
            
        case NSFetchedResultsChangeDelete: {
            [self.tblList deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tblList endUpdates];
}

#pragma mark - UI

- (TableHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = [[TableHeaderView alloc] initForPlaylistsVC];
        _headerView.delegate = self;
    }
    return _headerView;
}

- (void)selectUtility:(kHeaderUtilType)iType
{
    [[DataManagement sharedInstance] doUtility:iType withData:nil fromNavigation:self.navigationController];
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

- (void)openPlayer:(id)sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end

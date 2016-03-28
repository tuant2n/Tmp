//
//  SongsViewController.m
//  CloudMusic
//
//  Created by TuanTN on 3/6/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "SongsViewController.h"

#import "Utils.h"
#import "GlobalParameter.h"
#import "DataManagement.h"

@interface SongsViewController () <NSFetchedResultsControllerDelegate,MGSwipeTableCellDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,TableHeaderViewDelegate>
{
    BOOL isActiveSearch;
    NSString *sCurrentSearch;
}

@property (nonatomic, strong) PCSEQVisualizer *musicEq;
@property (nonatomic, strong) UIBarButtonItem *barMusicEq;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, weak) IBOutlet UITableView *tblList;
@property (nonatomic, weak) IBOutlet UITableView *tblSearchResult;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *keyboardLayout;
@property (nonatomic, weak) IBOutlet UIView *disableView;

@property (nonatomic, strong) NSMutableArray *arrResults;
@property (nonatomic, strong) TableFooterView *footerView;
@property (nonatomic, strong) TableHeaderView *headerView;

@end

@implementation SongsViewController

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
        NSFetchRequest *request = [[DataManagement sharedInstance] getListSongFilterByName:nil artistId:nil genreId:nil];
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[DataManagement sharedInstance] managedObjectContext] sectionNameKeyPath:@"sSongFirstLetter" cacheName:nil];
        _fetchedResultsController.delegate = self;
        
    }
    return _fetchedResultsController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self performFetch];
}

- (void)performFetch
{
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Fetch error: %@", error);
    }
    else {
        [self.tblList reloadData];
        [self setupFooterView];
    }
}

- (void)setupUI
{
    self.title = @"Songs";
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

- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL)isActive
{
    if (isActiveSearch == isActive) {
        return;
    }
    
    isActiveSearch = isActive;
    
    [self.arrResults removeAllObjects];
    sCurrentSearch = nil;
    
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
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.headerView setActiveSearchBar:isActiveSearch];
        [self.tblList setTableHeaderView:self.headerView];
    } completion:nil];
    
    self.tblList.allowsSelection = !isActiveSearch;
    self.tblList.scrollEnabled = !isActiveSearch;
    
    [self.tblList reloadSectionIndexTitles];
    [searchBar setShowsCancelButton:isActiveSearch animated:YES];
}

- (void)subscribeToKeyboard {
    [self an_subscribeKeyboardWithAnimations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {
        if (isShowing) {
            self.keyboardLayout.constant = CGRectGetHeight(keyboardRect);
        }
        else {
            self.keyboardLayout.constant = [[[self tabBarController] tabBar] bounds].size.height;
        }
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
    [self doSearch:searchString];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self doSearch:searchBar.text];
}

- (void)doSearch:(NSString *)sSearch
{
    sSearch = [sSearch stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (sSearch.length <= 0 || [sSearch isEqualToString:sCurrentSearch])
    {
        return;
    }
    
    [self.arrResults removeAllObjects];
    sCurrentSearch = sSearch;
    
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

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if(index == 0) [tableView scrollRectToVisible:tableView.tableHeaderView.frame animated: NO];
    return (index - 1);
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.tblSearchResult || isActiveSearch) {
        return nil;
    }
    else {
        NSMutableArray *arrList = [[NSMutableArray alloc] initWithArray:[self.fetchedResultsController sectionIndexTitles]];
        [arrList insertObject:UITableViewIndexSearch atIndex:0];
        return arrList;
    }
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
        SearchResultObj *resultOj = self.arrResults[section];
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
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tblSearchResult) {
        SearchResultObj *resultOj = self.arrResults[section];
        return resultOj.resuls.count;
    }
    else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        return [sectionInfo numberOfObjects];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [Utils normalCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tblSearchResult) {
        SearchResultObj *resultOj = self.arrResults[indexPath.section];
        id itemObj = resultOj.resuls[indexPath.row];
        return [self configCellWithItem:itemObj atIndex:indexPath tableView:tableView];
    }
    else {
        SongsCell *cell = (SongsCell *)[tableView dequeueReusableCellWithIdentifier:@"SongsCellId" forIndexPath:indexPath];
        cell.delegate = self;
        cell.allowsMultipleSwipe = NO;
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][indexPath.section];
        [cell setLineHidden:(indexPath.row == [sectionInfo numberOfObjects] - 1)];
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }
}

- (void)configureCell:(SongsCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configWithItem:item];
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
        Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if (item.isCloud.boolValue && index == 0) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Fetched Results Controller Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
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
    [self setupFooterView];
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
    int itemCount = (int)[self.fetchedResultsController.fetchedObjects count];
    
    if (itemCount <= 1) {
        sContent = [NSString stringWithFormat:@"%d Song",itemCount];
    }
    else {
         sContent = [NSString stringWithFormat:@"%d Songs",itemCount];
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

- (void)hideHeaderView
{
    if (self.tblList.tableHeaderView) {
        self.tblList.contentOffset = CGPointMake(0.0, self.tblList.tableHeaderView.bounds.size.height);
    }
}

- (void)selectUtility:(kHeaderUtilType)iType
{
    if (iType == kHeaderUtilTypeCreatePlaylist) {
        
    }
    else if (iType == kHeaderUtilTypeShuffle) {
        
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

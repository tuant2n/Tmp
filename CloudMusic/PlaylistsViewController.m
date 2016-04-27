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

#import "UIAlertView+Blocks.h"

@interface PlaylistsViewController () <NSFetchedResultsControllerDelegate,MGSwipeTableCellDelegate,UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource,TableHeaderViewDelegate,MainCellDelegate>
{
    NSString *sCurrentSearch;
}

@property (nonatomic, strong) PCSEQVisualizer *musicEq;
@property (nonatomic, strong) UIBarButtonItem *barMusicEq;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, weak) IBOutlet UITableView *tblList;
@property (nonatomic, strong) UISearchDisplayController *searchDisplay;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeSearch) name:NOTIFICATION_RELOAD_DATA object:nil];
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
    self.edgesForExtendedLayout = UIRectEdgeBottom;

    [Utils configTableView:self.tblList];
    [self setupHeaderBar];
    [self.tblList setTableFooterView:[Utils tableLine]];
}

- (void)setupHeaderBar
{
    [self.tblList setTableHeaderView:self.headerView];
    
    self.searchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:self.headerView.searchBar contentsController:self];
    self.searchDisplay.searchResultsDataSource = self;
    self.searchDisplay.searchResultsDelegate = self;
    self.searchDisplay.delegate = self;
}

- (UINavigationController *)navigationController {
    return nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView != self.tblList) {
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
    
    if (tableView != self.tblList) {
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
    if (tableView != self.tblList) {
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
    
    if (tableView != self.tblList) {
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

        MainCell *mainCell = (MainCell *)cell;
        mainCell.delegate = self;
        mainCell.subDelegate = self;
        mainCell.allowsMultipleSwipe = NO;
        
        if (tableView != self.tblList) {
            DataObj *resultOj = self.arrResults[indexPath.section];
            cellItem = resultOj.listData[indexPath.row];
            
            [mainCell configWithoutMenu:cellItem];
            [mainCell setLineHidden:(indexPath.row == [resultOj.listData count] - 1)];
        }
        else {
            cellItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
            [mainCell config:cellItem];
            
            id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][indexPath.section];
            [mainCell setLineHidden:(indexPath.row == [sectionInfo numberOfObjects] - 1)];
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
        itemObj = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    if (itemObj) {
        [[DataManagement sharedInstance] doActionWithItem:itemObj withData:nil fromSearch:(tableView != self.tblList) fromNavigation:[super navigationController]];
    }
}

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    NSIndexPath *indexPath = [self.tblList indexPathForCell:cell];
    id itemObj = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (!itemObj) {
        return YES;
    }
    
    return [[DataManagement sharedInstance] doSwipeActionWithItem:itemObj atIndex:index isLeftAction:(direction == MGSwipeDirectionLeftToRight) fromNavigation:[super navigationController]];
}

- (void)changePlaylistName:(Playlist *)playlist
{
    __block Playlist *editPlaylist = playlist;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Edit Playlist Title" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *tfPlaylistName = [alertView textFieldAtIndex:0];
    tfPlaylistName.autocapitalizationType = UITextAutocapitalizationTypeWords;
    tfPlaylistName.placeholder = @"Playlist Title";
    tfPlaylistName.text = editPlaylist.sPlaylistName;
    
    alertView.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex)
    {
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        }
        
        NSString *sNewName = [[alertView textFieldAtIndex:0] text];
        if ([[DataManagement sharedInstance] getPlaylistWithType:kPlaylistTypeNormal andName:sNewName])
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Playlist with such name already exists." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            return;
        }
        else {
            editPlaylist.sPlaylistName = sNewName;
            [[DataManagement sharedInstance] saveData:NO];
        }
    };
    
    alertView.shouldEnableFirstOtherButtonBlock = ^BOOL(UIAlertView *alertView)
    {
        NSString *sTmpName = [[alertView textFieldAtIndex:0] text];
        
        if ([sTmpName isEqualToString:editPlaylist.sPlaylistName]) {
            return NO;
        }
        else {
            return sTmpName.length;
        }
    };
    
    [alertView show];
}

#pragma mark - Fetched Results Controller Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self closeSearch];
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

- (void)configureCell:(MainCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell config:item];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][indexPath.section];
    BOOL isHiddenSeperator = (indexPath.row == [sectionInfo numberOfObjects] - 1);
    [cell setLineHidden:isHiddenSeperator];
}

#pragma mark - UISearchDisplayControllerDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [tableView setContentInset:UIEdgeInsetsMake(SEARCHBAR_HEIGHT, 0.0, 0.0, 0.0)];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsMake(SEARCHBAR_HEIGHT, 0.0, 0.0, 0.0)];
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
    
    [[DataManagement sharedInstance] search:sCurrentSearch searchType:kSearchTypeFile block:^(NSArray *results)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (results) {
                 [self.arrResults removeAllObjects];
                 [self.arrResults addObjectsFromArray:results];
                 [self.searchDisplay.searchResultsTableView reloadData];
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
    
    [self.arrResults removeAllObjects];
    sCurrentSearch = nil;
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
    [[DataManagement sharedInstance] doUtility:iType withData:nil fromNavigation:[super navigationController]];
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
    [[GlobalParameter sharedInstance] openPlayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end

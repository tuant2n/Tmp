//
//  FilesViewController.m
//  CloudMusic
//
//  Created by TuanTN on 3/6/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "FilesViewController.h"

#import "Utils.h"
#import "GlobalParameter.h"
#import "DataManagement.h"

#import "DropBoxManagementViewController.h"

@interface FilesViewController () <NSFetchedResultsControllerDelegate,MGSwipeTableCellDelegate,UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSString *sCurrentSearch;
}

@property (nonatomic, strong) PCSEQVisualizer *musicEq;
@property (nonatomic, strong) UIBarButtonItem *barMusicEq;
@property (nonatomic, strong) UIBarButtonItem *barBtnAddFile;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, weak) IBOutlet UIView *vNotFound;
@property (nonatomic, weak) IBOutlet UIButton *btnConnectDropbox;

@property (nonatomic, weak) IBOutlet UITableView *tblList;
@property (nonatomic, strong) UISearchDisplayController *searchDisplay;

@property (nonatomic, strong) NSMutableArray *arrResults;
@property (nonatomic, strong) TableFooterView *footerView;
@property (nonatomic, strong) TableHeaderView *headerView;

@end

@implementation FilesViewController

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
        NSFetchRequest *request = [[DataManagement sharedInstance] getFileFilterByName:nil];
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[DataManagement sharedInstance] managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
        
    }
    return _fetchedResultsController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    [self performFetch];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:NOTIFICATION_LOGIN_DROPBOX object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeSearch) name:NOTIFICATION_RELOAD_DATA object:nil];
}

- (void)performFetch
{
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        TTLog(@"Fetch error: %@", error);
    }
    else {
        [self.tblList reloadData];
        [self setupFooterView];
    }
}

- (void)setupUI
{
    self.title = @"File";
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.barMusicEq,self.barBtnAddFile,nil];
    self.edgesForExtendedLayout = UIRectEdgeBottom;

    [self.btnConnectDropbox setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnConnectDropbox setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.btnConnectDropbox setBackgroundImage:[Utils imageWithColor:0x017ee6] forState:UIControlStateNormal];
    self.btnConnectDropbox.layer.cornerRadius = 5.0;
    self.btnConnectDropbox.clipsToBounds = YES;
    
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
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
        [self setShowNotFoundView:[sectionInfo numberOfObjects] <= 0];
        
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
        DataObj *resultObj = self.arrResults[indexPath.section];
        cellItem = resultObj.listData[indexPath.row];
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
        MainCell *mainCell = (MainCell *)cell;
        mainCell.delegate = self;
        mainCell.allowsMultipleSwipe = NO;
        
        id cellItem = nil;

        if (tableView != self.tblList) {
            DataObj *resultObj = self.arrResults[indexPath.section];
            cellItem = resultObj.listData[indexPath.row];
            
            [mainCell configWithoutMenu:cellItem];
            [mainCell setLineHidden:(indexPath.row == [resultObj.listData count] - 1)];
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
            [self configureCell:(FilesCell *)[self.tblList cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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

#pragma mark - DropBox Connect

- (IBAction)touchConnectDropbox:(id)sender
{
    [self connectToDropbox];
}

- (void)connectToDropbox
{
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
    else {
        [self gotoDropbox];
    }
}

- (void)loginSuccess:(NSNotification *)notification
{
    [self gotoDropbox];
}

- (void)gotoDropbox
{
    DropBoxManagementViewController *vc = [[DropBoxManagementViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [[super navigationController] pushViewController:vc animated:YES];
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
    
    if (itemCount == 1) {
        sContent = [NSString stringWithFormat:@"%d File",itemCount];
    }
    else {
        sContent = [NSString stringWithFormat:@"%d Files",itemCount];
    }
    
    [self.footerView setContent:sContent];
}

- (TableHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = [[TableHeaderView alloc] initForFilesVC];
    }
    return _headerView;
}

#pragma mark - Utils

- (void)setShowNotFoundView:(BOOL)isShow
{
    if (isShow) {
        self.vNotFound.hidden = NO;
        [self.view bringSubviewToFront:self.vNotFound];
    }
    else {
        self.vNotFound.hidden = YES;
        [self.view sendSubviewToBack:self.vNotFound];
    }
}

- (UIBarButtonItem *)barBtnAddFile
{
    if (!_barBtnAddFile) {
        _barBtnAddFile = [[UIBarButtonItem alloc] initWithCustomView:[Utils createBarButton:@"icn-add-music-normal.png" position:UIControlContentHorizontalAlignmentRight target:self selector:@selector(touchConnectDropbox:)]];
    }
    return _barBtnAddFile;
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

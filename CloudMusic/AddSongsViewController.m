//
//  AddSongsViewController.m
//  CloudMusic
//
//  Created by TuanTN8 on 4/22/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "AddSongsViewController.h"

#import "DataManagement.h"
#import "GlobalParameter.h"
#import "Utils.h"

#import "AddSongsCell.h"

#import "MBProgressHUD.h"

typedef enum {
    kFilterTypeAll,
    kFilterTypeiTunes,
    kFilterTypeDownloaded,
} kFilterType;

@interface AddSongsViewController () <UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,TableHeaderViewDelegate>
{
    kFilterType iFilterType;
    NSString *sLastSearchString;
}

@property (nonatomic, strong) NSMutableArray *arrNewPlaylist;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSFetchedResultsController *searchFetchedResultsController;

@property (nonatomic, strong) UIButton *btnDone, *btnCancel;
@property (nonatomic, strong) UIButton *btnFilter;

@property (nonatomic, weak) IBOutlet UITableView *tblList;

@property (nonatomic, strong) UISearchDisplayController *searchDisplay;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) TableFooterView *footerView;
@property (nonatomic, strong) TableHeaderView *headerView;

@end

@implementation AddSongsViewController

- (NSMutableArray *)arrNewPlaylist
{
    if (!_arrNewPlaylist) {
        _arrNewPlaylist = [[NSMutableArray alloc] initWithArray:self.currentListSongs];
    }
    return _arrNewPlaylist;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController)
    {
        NSFetchRequest *request = [[DataManagement sharedInstance] getSongFilterByName:nil albumId:nil artistId:nil genreId:nil];
        
        if (iFilterType == kFilterTypeDownloaded) {
            [request setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"iCloudItem",@1]];
        }
        else if (iFilterType == kFilterTypeiTunes) {
            [request setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"iCloudItem",@0]];
        }
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[DataManagement sharedInstance] managedObjectContext] sectionNameKeyPath:@"sSongFirstLetter" cacheName:nil];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

- (NSFetchedResultsController *)searchFetchedResultsController
{
    if (!_searchFetchedResultsController)
    {
        NSFetchRequest *request = [[DataManagement sharedInstance] getSongFilterByName:nil albumId:nil artistId:nil genreId:nil];
        
        NSMutableArray *filters = [NSMutableArray new];
        
        if (iFilterType == kFilterTypeDownloaded) {
            [filters addObject:[NSPredicate predicateWithFormat:@"%K == %@", @"iCloudItem",@1]];
        }
        else if (iFilterType == kFilterTypeiTunes) {
            [filters addObject:[NSPredicate predicateWithFormat:@"%K == %@", @"iCloudItem",@0]];
        }
        
        if (sLastSearchString) {
            [filters addObject:[NSPredicate predicateWithFormat:@"sSongNameIndex CONTAINS[cd] %@",sLastSearchString]];
        }
        
        [request setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:filters]];
        
        _searchFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[DataManagement sharedInstance] managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
        _searchFetchedResultsController.delegate = self;
    }
    return _searchFetchedResultsController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    [self fetchDataWithFilter:kFilterTypeAll];
}

- (void)fetchDataWithFilter:(kFilterType)iType
{
    iFilterType = iType;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        TTLog(@"Fetch error: %@", error);
    }
    else {
        NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:[self.currentPlaylist getPlaylist]];

        for (int i = 0; i < [self.fetchedResultsController sections].count; i++) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:i];
            for (Item *song in sectionInfo.objects) {
                song.numberOfSelect = (int)[countedSet countForObject:song.iSongId];
                [self.arrNewPlaylist insertObject:song atIndex:0];
            }
        }
        
        [self.tblList reloadData];
        [self configExternalView];
    }
}

- (void)setupUI
{
    self.title = @"Songs";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnCancel];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnDone];
    [Utils configNavigationController:self.navigationController];

    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setToolbarItems:[NSArray arrayWithObjects:spaceItem,[[UIBarButtonItem alloc] initWithCustomView:self.btnFilter],spaceItem,nil] animated:NO];
    
    [self setupSearchBar];
    [Utils configTableView:self.tblList isSearch:NO];
}

- (void)setupSearchBar
{
    [Utils configSearchBar:self.searchBar];
    
    self.searchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplay.searchResultsDataSource = self;
    self.searchDisplay.searchResultsDelegate = self;
    self.searchDisplay.delegate = self;
}

- (UINavigationController *)navigationController {
    return nil;
}

#pragma mark - UITableViewDataSource

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return tableView == self.tblList ? self.fetchedResultsController : self.searchFetchedResultsController;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return tableView == self.tblList ? index : 0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return tableView == self.tblList ? [[NSMutableArray alloc] initWithArray:[self.fetchedResultsController sectionIndexTitles]] : nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsControllerForTableView:tableView] sections] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return tableView == self.tblList ? [HeaderTitle height] : 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sTitle = [self tableView:tableView titleForHeaderInSection:section];
    HeaderTitle *header = (HeaderTitle *)[tableView dequeueReusableCellWithIdentifier:@"HeaderTitleId"];
    [header setTitle:sTitle];
    return header;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsControllerForTableView:tableView] sections][section];
    return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MainCell normalCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (AddSongsCell *)[tableView dequeueReusableCellWithIdentifier:@"AddSongsCellId" forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![cell isKindOfClass:[MainCell class]])
    {
        return;
    }
    
    Item *song = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    
    MainCell *mainCell = (MainCell *)cell;
    [mainCell configWithoutMenu:song];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsControllerForTableView:tableView] sections][indexPath.section];
    [mainCell setLineHidden:(indexPath.row == [sectionInfo numberOfObjects] - 1)];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[AddSongsCell class]]) {
        AddSongsCell *addSongsCell = (AddSongsCell *)cell;
        [addSongsCell removeObserver];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Item *song = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    song.numberOfSelect += 1;
    [self.arrNewPlaylist insertObject:song atIndex:0];
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
    [self configExternalView];
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

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [controller.searchResultsTableView setContentInset:UIEdgeInsetsZero];
    [controller.searchResultsTableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    [controller.searchResultsTableView setTableFooterView:[Utils tableLine]];
    controller.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [controller.searchResultsTableView registerNib:[UINib nibWithNibName:@"AddSongsCell" bundle:nil] forCellReuseIdentifier:@"AddSongsCellId"];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    sLastSearchString = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (!searchString || [searchString isEqualToString:sLastSearchString]) {
        return NO;
    }
    
    sLastSearchString = searchString;
    
    self.searchFetchedResultsController = nil;
    [self.searchFetchedResultsController performFetch:nil];
    
    return YES;
}

#pragma mark - TableHeaderViewDelegate

- (void)selectUtility:(kHeaderUtilType)iType
{
    if (iType != kHeaderUtilTypeAddAllSongs) {
        return;
    }
    
    for (int i = 0; i < [self.fetchedResultsController sections].count; i++) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:i];
        for (Item *song in sectionInfo.objects) {
            song.numberOfSelect += 1;
            [self.arrNewPlaylist insertObject:song atIndex:0];
        }
    }
}

#pragma mark - Done

- (void)touchDone
{
    if ([self.delegate respondsToSelector:@selector(getNewPlaylistItems:)]) {
        [self.delegate getNewPlaylistItems:self.arrNewPlaylist];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)configExternalView
{
    int itemCount = (int)[self.fetchedResultsController.fetchedObjects count];
    if (itemCount <= 0)
    {
        [self.tblList setTableHeaderView:[UIView new]];
        [self.tblList setTableFooterView:[UIView new]];
        return;
    }
    
    NSString *sContent = nil;
    
    if (itemCount == 1) {
        sContent = [NSString stringWithFormat:@"%d Song",itemCount];
    }
    else {
        sContent = [NSString stringWithFormat:@"%d Songs",itemCount];
    }
    
    [self.footerView setContent:sContent];
    
    [self.navigationController setToolbarHidden:!NO animated:YES];
    [self.tblList setTableHeaderView:self.headerView];
    [self.tblList setTableFooterView:self.footerView];
}

- (TableHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = [[TableHeaderView alloc] initForAddSongsVC];
        _headerView.delegate = self;
    }
    return _headerView;
}

- (UIButton *)btnDone
{
    if (!_btnDone) {
        _btnDone = [Utils createBarButtonWithTitle:@"Done" font:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0] textColor:0x017ee6 position:UIControlContentHorizontalAlignmentRight target:self action:@selector(touchDone)];
    }
    return _btnDone;
}

- (UIButton *)btnCancel
{
    if (!_btnCancel) {
        _btnCancel = [Utils createBarButtonWithTitle:@"Cancel" font:[UIFont fontWithName:@"HelveticaNeue" size:16.0] textColor:0x017ee6 position:UIControlContentHorizontalAlignmentLeft target:self action:@selector(touchCancel)];
    }
    return _btnCancel;
}

- (UIButton *)btnFilter
{
    if (!_btnCancel) {
        _btnCancel = [Utils createBarButtonWithTitle:@"All" font:[UIFont fontWithName:@"HelveticaNeue" size:16.0] textColor:0x017ee6 image:@"btnFilter" position:UIControlContentHorizontalAlignmentCenter target:self selector:@selector(touchDone)];
    }
    return _btnCancel;
}

- (void)touchCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

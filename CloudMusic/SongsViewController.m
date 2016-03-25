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

#import "SongsCell.h"
#import "SongHeaderTitle.h"

#import "TableFooterView.h"
#import "TableHeaderView.h"

#import "PCSEQVisualizer.h"
#import "MGSwipeButton.h"

@interface SongsViewController () <NSFetchedResultsControllerDelegate,MGSwipeTableCellDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource>
{

}

@property (nonatomic, strong) PCSEQVisualizer *musicEq;
@property (nonatomic, strong) UIBarButtonItem *barMusicEq;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic) UISearchDisplayController *searchDisplay;

@property (nonatomic, weak) IBOutlet UITableView *tblList;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingView;

@property (nonatomic, strong) TableFooterView *footerView;
@property (nonatomic, strong) TableHeaderView *headerView;

@end

@implementation SongsViewController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Item class])];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sSongNameIndex" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        
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
        [self setupFooterView];
    }
    [self setShowLoadingView:NO];
}

- (void)setupUI
{
    self.title = @"Songs";
    self.navigationItem.rightBarButtonItem = self.barMusicEq;
    
    self.tblList.sectionIndexColor = [Utils colorWithRGBHex:0x006bd5];
    self.tblList.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tblList.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    
    [self.tblList registerNib:[UINib nibWithNibName:@"SongsCell" bundle:nil] forCellReuseIdentifier:@"SongsCellId"];
    [self.tblList registerNib:[UINib nibWithNibName:@"SongHeaderTitle" bundle:nil] forCellReuseIdentifier:@"SongHeaderTitleId"];

    [self setupHeaderBar];
    [self.tblList setTableFooterView:self.footerView];
    
    [self setShowLoadingView:YES];
}

- (void)setupHeaderBar
{
    [self.headerView setupForSongsVC];
    
    self.searchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:self.headerView.searchBar contentsController:self];
    self.searchDisplay.searchResultsDataSource = self;
    self.searchDisplay.searchResultsDelegate = self;
    self.searchDisplay.delegate = self;
    
    self.headerView.searchBar.delegate = self;
    
    [self.tblList setTableHeaderView:self.headerView];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self searchBar:searchBar activate:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = nil;
    [self searchBar:searchBar activate:NO];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some
    // api that you are using to do the search
//    NSArray *results = [SomeService doSearch:searchBar.text];
//    
//    [searchBar setShowsCancelButton:NO animated:YES];
//    [searchBar resignFirstResponder];
//    self.theTableView.allowsSelection = YES;
//    self.theTableView.scrollEnabled = YES;
//    
//    [self.tableData removeAllObjects];
//    [self.tableData addObjectsFromArray:results];
//    [self.theTableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active
{
    self.tblList.allowsSelection = !active;
    self.tblList.scrollEnabled = !active;
    
    if (!active) {
//        [disableViewOverlay removeFromSuperview];
        [searchBar resignFirstResponder];
    }
    else {
//        self.disableViewOverlay.alpha = 0;
//        [self.view addSubview:self.disableViewOverlay];
//        
//        [UIView beginAnimations:@"FadeIn" context:nil];
//        [UIView setAnimationDuration:0.5];
//        self.disableViewOverlay.alpha = 0.6;
//        [UIView commitAnimations];
//        
//        // probably not needed if you have a details view since you
//        // will go there on selection
//        NSIndexPath *selected = [self.theTableView
//                                 indexPathForSelectedRow];
//        if (selected) {
//            [self.theTableView deselectRowAtIndexPath:selected
//                                             animated:NO];
//        }
    }
    [searchBar setShowsCancelButton:active animated:YES];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.searchDisplayController.searchResultsTableView.tableFooterView = [UIView new];
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"SongsCell" bundle:nil] forCellReuseIdentifier:@"SongsCellId"];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"SongHeaderTitle" bundle:nil] forCellReuseIdentifier:@"SongHeaderTitleId"];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{

}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{

    return YES;
}

#pragma mark - UITableViewDataSource

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *arrList = [[NSMutableArray alloc] initWithArray:[self.fetchedResultsController sectionIndexTitles]];
    [arrList insertObject:UITableViewIndexSearch atIndex:0];
    return arrList;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if(index == 0) [tableView scrollRectToVisible:tableView.tableHeaderView.frame animated: NO];
    return (index - 1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [SongHeaderTitle height];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    SongHeaderTitle *header = (SongHeaderTitle *)[tableView dequeueReusableCellWithIdentifier:@"SongHeaderTitleId"];
    [header setTitle:[self tableView:tableView titleForHeaderInSection:section]];
    return header.contentView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SongsCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SongsCell *cell = (SongsCell *)[tableView dequeueReusableCellWithIdentifier:@"SongsCellId" forIndexPath:indexPath];
    cell.delegate = self;
    cell.allowsMultipleSwipe = NO;
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][indexPath.section];
    [cell setLineHidden:(indexPath.row == [sectionInfo numberOfObjects] - 1)];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(SongsCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configWithItem:item];
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

- (void)setShowLoadingView:(BOOL)isShow
{
    if (isShow) {
        [self.loadingView startAnimating];
    }
    else {
        [self.loadingView startAnimating];
    }
    
    self.loadingView.hidden = !isShow;
    self.tblList.hidden = isShow;
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

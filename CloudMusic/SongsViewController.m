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

#import "SongCell.h"
#import "SongHeaderTitle.h"
#import "TableFooterCell.h"
#import "TableHeaderCell.h"

#import "PCSEQVisualizer.h"

@interface SongsViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) PCSEQVisualizer *musicEq;
@property (nonatomic, strong) UIBarButtonItem *barMusicEq;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, weak) IBOutlet UITableView *tblList;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingView;

@property (nonatomic, strong) TableFooterCell *footerView;
@property (nonatomic, strong) TableHeaderCell *headerView;

@end

@implementation SongsViewController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        
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
    
    [self.tblList registerNib:[UINib nibWithNibName:@"SongCell" bundle:nil] forCellReuseIdentifier:@"SongCellId"];
    [self.tblList registerNib:[UINib nibWithNibName:@"SongHeaderTitle" bundle:nil] forCellReuseIdentifier:@"SongHeaderTitleId"];

    [self.tblList setTableHeaderView:self.headerView.contentView];
    [self.tblList setTableFooterView:self.footerView.contentView];
    
    [self setShowLoadingView:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.fetchedResultsController sectionIndexTitles];
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
    return [SongCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SongCell *cell = (SongCell *)[tableView dequeueReusableCellWithIdentifier:@"SongCellId" forIndexPath:indexPath];
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][indexPath.section];
    [cell setLineHidden:(indexPath.row == [sectionInfo numberOfObjects] - 1)];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(SongCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configWithItem:item];
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
            [self configureCell:(SongCell *)[self.tblList cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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

- (TableFooterCell *)footerView
{
    if (!_footerView) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TableFooterCell" owner:self options:nil];
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

- (TableHeaderCell *)headerView
{
    if (!_headerView) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TableHeaderCell" owner:self options:nil];
        if ([nib count] > 0) {
            _headerView = [nib objectAtIndex:0];
        }
    }
    return _headerView;
}

- (void)hideHeaderView
{
    if (self.tblList.tableHeaderView) {
//        self.tblList.contentOffset = CGPointMake(0,self.headerView.contentView.bounds.size.height);
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
    [self setShowLoadingView:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

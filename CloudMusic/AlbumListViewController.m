//
//  AlbumListViewController.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/29/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "AlbumListViewController.h"

#import "Utils.h"
#import "GlobalParameter.h"
#import "DataManagement.h"

@interface AlbumListViewController () <NSFetchedResultsControllerDelegate,MGSwipeTableCellDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,TableHeaderViewDelegate>
{
    BOOL isActiveSearch;
    NSString *sCurrentSearch;
}

@property (nonatomic, strong) PCSEQVisualizer *musicEq;
@property (nonatomic, strong) UIBarButtonItem *barMusicEq;

@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, weak) IBOutlet UITableView *tblList;

@property (nonatomic, strong) TableFooterView *footerView;
@property (nonatomic, strong) TableHeaderView *headerView;

@end

@implementation AlbumListViewController

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

- (void)pop
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)getData
{
    [self.arrData removeAllObjects];
    
    NSFetchRequest *request = [[DataManagement sharedInstance] getSongFilterByName:nil albumId:self.currentAlbum.iAlbumId artistId:nil genreId:self.currentAlbum.iGenreId];
    NSArray *listSong = [[DataManagement sharedInstance].managedObjectContext executeFetchRequest:request error:nil];
    [self.arrData addObjectsFromArray:listSong];
    [self.tblList reloadData];
    [self setupFooterView];
}

- (void)reloadData:(NSNotification *)notification
{
    [self getData];
}

- (void)setupUI
{
    self.title = self.currentAlbum.sAlbumName;
    self.navigationItem.rightBarButtonItem = self.barMusicEq;
    [Utils configNavigationController:self.navigationController];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    [Utils configTableView:self.tblList];
    [self.tblList setTableHeaderView:self.headerView];
    [self.tblList setTableFooterView:self.footerView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ListSongCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (ListSongCell *)[tableView dequeueReusableCellWithIdentifier:@"ListSongCellId" forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[ListSongCell class]]) {
        id cellItem = self.arrData[indexPath.row];
        
        ListSongCell *listSongCell = (ListSongCell *)cell;
        listSongCell.delegate = self;
        listSongCell.allowsMultipleSwipe = NO;
        
        [listSongCell setIndex:indexPath];
        [listSongCell config:cellItem];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id itemObj = self.arrData[indexPath.row];;
    
    if (itemObj) {
        [[DataManagement sharedInstance] doActionWithItem:itemObj withData:self.arrData fromSearch:isActiveSearch fromNavigation:self.navigationController];
    }
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
    int itemCount = (int)[self.arrData count];
    
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
        _headerView = [[TableHeaderView alloc] initForAlbumListVC:self.currentAlbum];
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

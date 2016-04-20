//
//  PlaylistsListSongViewController.m
//  CloudMusic
//
//  Created by TuanTN8 on 4/20/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "PlaylistsListSongViewController.h"

#import "DataManagement.h"
#import "GlobalParameter.h"
#import "Utils.h"

@interface PlaylistsListSongViewController () <MGSwipeTableCellDelegate,TableHeaderViewDelegate>

@property (nonatomic, strong) PCSEQVisualizer *musicEq;
@property (nonatomic, strong) UIBarButtonItem *barMusicEq;

@property (nonatomic, strong) NSMutableArray *arrData, *arrPlaylist;

@property (nonatomic, weak) IBOutlet UIView *editView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *editViewHeight;
@property (nonatomic, weak) IBOutlet UIButton *btnEdit, *btnClear, *btnDelete;
@property (nonatomic, weak) IBOutlet UIView *line;

@property (nonatomic, weak) IBOutlet UITableView *tblList;

@property (nonatomic, strong) TableFooterView *footerView;
@property (nonatomic, strong) TableHeaderView *headerView;

@end

@implementation PlaylistsListSongViewController

- (NSMutableArray *)arrData
{
    if (!_arrData) {
        _arrData = [[NSMutableArray alloc] init];
    }
    return _arrData;
}

- (NSMutableArray *)arrPlaylist
{
    if (!_arrPlaylist) {
        _arrPlaylist = [[NSMutableArray alloc] init];
        [_arrPlaylist addObjectsFromArray:[self.currentPlaylist getPlaylist]];
    }
    return _arrPlaylist;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    [self getData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:NOTIFICATION_RELOAD_DATA object:nil];
}

- (void)getData
{
    NSFetchRequest *fetchSong = [[DataManagement sharedInstance] getSongFilterByName:nil albumId:nil artistId:nil genreId:nil];
    [fetchSong setPredicate:[NSPredicate predicateWithFormat:@"ANY iSongId IN %@",self.arrPlaylist]];

    [self.arrData removeAllObjects];
    NSArray *results = [[DataManagement sharedInstance].managedObjectContext executeFetchRequest:fetchSong error:nil];
    [self.arrData addObjectsFromArray:results];
    [self.tblList reloadData];
    
    [self setupFooterView];
}

- (void)setupUI
{
    self.title = self.currentPlaylist.sPlaylistName;
    self.navigationItem.rightBarButtonItem = self.barMusicEq;
    [Utils configNavigationController:self.navigationController];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    [Utils configTableView:self.tblList isSearch:YES];
    [self setupEditView];
    
    [self.tblList setTableFooterView:self.footerView];
    [self.tblList setTableHeaderView:self.headerView];
    
}

- (void)setupEditView
{
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    [self setEnableAction:(self.arrPlaylist.count > 0)];
    [self setEnableEditView:!self.currentPlaylist.isSmartPlaylist];
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MainCell normalCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cellItem = self.arrData[indexPath.row];
    return [Utils getCellWithItem:cellItem atIndex:indexPath tableView:tableView];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[MainCell class]])
    {
        id cellItem = self.arrData[indexPath.row];

        MainCell *mainCell = (MainCell *)cell;
        mainCell.delegate = self;
        mainCell.allowsMultipleSwipe = NO;
        
        [mainCell config:cellItem];
        [mainCell setLineHidden:(indexPath.row == self.arrData.count - 1)];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id itemObj = self.arrData[indexPath.row];
    [[DataManagement sharedInstance] doActionWithItem:itemObj withData:nil fromSearch:NO fromNavigation:self.navigationController];
}

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    NSIndexPath *indexPath = [self.tblList indexPathForCell:cell];
    if (!indexPath) {
        return YES;
    }
    
    id itemObj = self.arrData[indexPath.row];;
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
    int itemCount = (int)[self.arrData count];
    
    if (itemCount == 1) {
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
        _headerView = [[TableHeaderView alloc] initForPlaylistsListSongVC];
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

- (void)openPlayer:(id)sender
{
    
}

#pragma mark - Utils

- (void)setEnableAction:(BOOL)isEnable
{
    self.btnEdit.enabled = isEnable;
    self.btnClear.enabled = isEnable;
}

- (void)setEnableEditView:(BOOL)isEnable
{
    if (isEnable) {
        [self.editViewHeight setConstant:40.0];
        self.editView.hidden = NO;
    }
    else {
        [self.editViewHeight setConstant:0.0];
        self.editView.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

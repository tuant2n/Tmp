//
//  PlaylistsListSongViewController.m
//  CloudMusic
//
//  Created by TuanTN8 on 4/20/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "PlaylistsListSongViewController.h"

#import "AddSongsViewController.h"

#import "DataManagement.h"
#import "GlobalParameter.h"
#import "Utils.h"

#import "UIAlertView+Blocks.h"

@interface PlaylistsListSongViewController () <MGSwipeTableCellDelegate,TableHeaderViewDelegate>

@property (nonatomic, strong) PCSEQVisualizer *musicEq;
@property (nonatomic, strong) UIBarButtonItem *barMusicEq;
@property (nonatomic, strong) UIBarButtonItem *barBtnAddSong;

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
    [self configExternalView];
}

- (void)setupUI
{
    self.title = self.currentPlaylist.sPlaylistName;
    
    if (self.currentPlaylist.isSmartPlaylist.boolValue) {
        self.navigationItem.rightBarButtonItem = self.barMusicEq;
    }
    else {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.barMusicEq,self.barBtnAddSong,nil];
    }
    
    [Utils configNavigationController:self.navigationController];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    [Utils configTableView:self.tblList isSearch:YES];
    [self setupEditView];
}

- (void)setupEditView
{
    self.line.backgroundColor = [Utils colorWithRGBHex:0xe4e4e4];
    [self setEnableAction:(self.arrPlaylist.count > 0)];
    [self setEnableEditView:!self.currentPlaylist.isSmartPlaylist.boolValue];
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
    
    return [[DataManagement sharedInstance] doSwipeActionWithItem:itemObj atIndex:index isLeftAction:(direction == MGSwipeDirectionLeftToRight) fromNavigation:self.navigationController];
}

#pragma mark - Method

- (IBAction)touchEdit:(id)sender
{
    
}

- (IBAction)touchClear:(id)sender
{
    [UIAlertView showWithTitle:@"Are you sure you want to clear this playlist?"
                       message:nil
             cancelButtonTitle:@"OK"
             otherButtonTitles:@[@"Cancel"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
         if (buttonIndex != [alertView cancelButtonIndex]) {
             return;
         }
         
         [self.arrData removeAllObjects];
         [self.tblList reloadData];
         [self configExternalView];
         
         [self.currentPlaylist setPlaylist:[NSArray new]];
         self.currentPlaylist.fDuration = @(0);
         
         [[DataManagement sharedInstance] saveData:NO];
     }];
}

- (IBAction)touchDelete:(id)sender
{
    [UIAlertView showWithTitle:@"Are you sure you want to delete this playlist?"
                       message:nil
             cancelButtonTitle:@"OK"
             otherButtonTitles:@[@"Cancel"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
         if (buttonIndex != [alertView cancelButtonIndex]) {
             return;
         }
         
         [[DataManagement sharedInstance] deletePlaylist:self.currentPlaylist];
         [self.navigationController popViewControllerAnimated:YES];
     }];
}

- (void)touchAddSong
{
    AddSongsViewController *vc = [[AddSongsViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
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
    int itemCount = (int)[self.arrData count];
    if (itemCount <= 0) {
        [self.tblList setTableFooterView:[UIView new]];
        [self.tblList setTableHeaderView:[UIView new]];
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
    [self.tblList setTableFooterView:self.footerView];
    [self.tblList setTableHeaderView:self.headerView];
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

- (UIBarButtonItem *)barBtnAddSong
{
    if (!_barBtnAddSong) {
        _barBtnAddSong = [[UIBarButtonItem alloc] initWithCustomView:[Utils createBarButton:@"btnAddSongToPlaylist.png" position:UIControlContentHorizontalAlignmentCenter target:self selector:@selector(touchAddSong)]];
    }
    return _barBtnAddSong;
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
        [self.editViewHeight setConstant:38.0];
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

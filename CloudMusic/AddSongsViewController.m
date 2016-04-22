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

@interface AddSongsViewController () <TableHeaderViewDelegate>

@property (nonatomic, strong) NSMutableArray *arrListData;
@property (nonatomic, strong) NSMutableArray *arrNewPlaylist;

@property (nonatomic, strong) UIButton *btnDone, *btnCancel;
@property (nonatomic, weak) IBOutlet UITableView *tblList;

@property (nonatomic, strong) TableFooterView *footerView;
@property (nonatomic, strong) TableHeaderView *headerView;

@end

@implementation AddSongsViewController

- (NSMutableArray *)arrListData
{
    if (!_arrListData) {
        _arrListData = [[NSMutableArray alloc] init];
    }
    return _arrListData;
}

- (NSMutableArray *)arrNewPlaylist
{
    if (!_arrNewPlaylist) {
        _arrNewPlaylist = [[NSMutableArray alloc] init];
    }
    return _arrNewPlaylist;
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
    NSOperationQueue *syncDataQueue = [[NSOperationQueue alloc] init];
    syncDataQueue.name = @"queue.get.listsong";
    
    [syncDataQueue addOperationWithBlock:^{
        [self.arrListData removeAllObjects];
        [self.arrListData addObjectsFromArray:[[DataManagement sharedInstance] getListSongFilterByName:nil albumId:nil artistId:nil genreId:nil]];
        
        NSArray *arrCurrentPlaylist = [self.currentPlaylist getPlaylist];
        
        [self.arrNewPlaylist removeAllObjects];
        [self.arrNewPlaylist addObjectsFromArray:arrCurrentPlaylist];
        
        NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:arrCurrentPlaylist];
        for (Item *song in self.arrListData) {
            song.numberOfSelect = (int)[countedSet countForObject:song.iSongId];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tblList reloadData];
            [self configExternalView];
        });
    }];
}

- (void)setupUI
{
    self.title = @"Songs";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnCancel];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnDone];
    [Utils configNavigationController:self.navigationController];
    self.edgesForExtendedLayout = UIRectEdgeBottom;

    [Utils configTableView:self.tblList isSearch:NO];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrListData.count;
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
    
    Item *song = self.arrListData[indexPath.row];
    
    MainCell *mainCell = (MainCell *)cell;

    [mainCell configWithoutMenu:song];
    [mainCell setLineHidden:(indexPath.row == [self.arrListData count] - 1)];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[AddSongsCell class]]) {
        AddSongsCell *addSongsCell = (AddSongsCell *)cell;
        [addSongsCell removeObserver];
    }
}

#pragma mark - Action

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Item *song = self.arrListData[indexPath.row];
    song.numberOfSelect += 1;
    [self.arrNewPlaylist insertObject:song.iSongId atIndex:0];
}

- (void)selectUtility:(kHeaderUtilType)iType
{
    if (iType != kHeaderUtilTypeAddAllSongs) {
        return;
    }
    
    for (Item *song in self.arrListData) {
        song.numberOfSelect += 1;
        [self.arrNewPlaylist insertObject:song.iSongId atIndex:0];
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
    int itemCount = (int)[self.arrListData count];
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

- (void)touchCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

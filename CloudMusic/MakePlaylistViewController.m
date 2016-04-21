//
//  MakePlaylistViewController.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/31/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "MakePlaylistViewController.h"

#import "CreatePlaylistViewController.h"

#import "DataManagement.h"
#import "GlobalParameter.h"
#import "Utils.h"

#import "MBProgressHUD.h"

@interface MakePlaylistViewController ()

@property (nonatomic, strong) NSMutableArray *arrListData;

@property (nonatomic, strong) UIButton *btnDone, *btnCancel;
@property (nonatomic, weak) IBOutlet UITableView *tblList;

@end

@implementation MakePlaylistViewController

- (NSMutableArray *)arrListData
{
    if (!_arrListData) {
        _arrListData = [[NSMutableArray alloc] init];
    }
    return _arrListData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self setupData];
}

- (void)setupUI
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnCancel];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnDone];
    [self setNumberOfSelect:0];
    
    [Utils configNavigationController:self.navigationController];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    [Utils configTableView:self.tblList isSearch:YES];
    [self.tblList setTableHeaderView:[Utils tableLine]];
}

- (void)setupData
{
    [self.arrListData removeAllObjects];
    
    if (self.arrListItem) {
        [self.arrListData addObjectsFromArray:self.arrListItem];
    }
    else {
        [self.arrListData addObjectsFromArray:[[DataManagement sharedInstance] getListSongFilterByName:nil albumId:nil artistId:nil genreId:nil]];
    }
    
    [self.tblList reloadData];
    
    self.tblList.allowsMultipleSelectionDuringEditing = YES;
    [self.tblList setEditing:YES animated:NO];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrListData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cellItem = self.arrListData[indexPath.row];
    if ([cellItem isKindOfClass:[AlbumObj class]]) {
        return [MainCell largeCellHeight];
    }
    else {
        return [MainCell normalCellHeight];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cellItem = self.arrListData[indexPath.row];
    return [Utils getCellWithItem:cellItem atIndex:indexPath tableView:tableView];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[MainCell class]])
    {
        id cellItem = self.arrListData[indexPath.row];
        
        MainCell *mainCell = (MainCell *)cell;
        mainCell.allowsMultipleSwipe = NO;
        
        [mainCell config:cellItem];
        [mainCell setLineHidden:(indexPath.row == [self.arrListData count] - 1)];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *selectedRows = [tableView indexPathsForSelectedRows];
    [self setNumberOfSelect:(int)selectedRows.count];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *selectedRows = [tableView indexPathsForSelectedRows];
    [self setNumberOfSelect:(int)selectedRows.count];
}

- (void)touchDone
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    NSOperationQueue *getListSong = [[NSOperationQueue alloc] init];
    getListSong.name = @"queue.sync.data";
    
    [getListSong addOperationWithBlock:^{
        NSMutableArray *listSong = [[NSMutableArray alloc] init];
        
        for (NSIndexPath *indexPath in [self.tblList indexPathsForSelectedRows]) {
            id cellItem = self.arrListData[indexPath.row];
            
            if ([cellItem isKindOfClass:[Item class]]) {
                [listSong addObject:cellItem];
            }
            else if ([cellItem isKindOfClass:[AlbumArtistObj class]]) {
                AlbumArtistObj *albumArtist = (AlbumArtistObj *)cellItem;
                [listSong addObjectsFromArray:[[DataManagement sharedInstance] getListSongFilterByName:nil albumId:nil artistId:albumArtist.iAlbumArtistId genreId:nil]];
            }
            else if ([cellItem isKindOfClass:[GenreObj class]]) {
                GenreObj *genre = (GenreObj *)cellItem;
                [listSong addObjectsFromArray:[[DataManagement sharedInstance] getListSongFilterByName:nil albumId:nil artistId:nil genreId:genre.iGenreId]];
            }
            else if ([cellItem isKindOfClass:[AlbumObj class]]) {
                AlbumObj *album = (AlbumObj *)cellItem;
                [listSong addObjectsFromArray:[[DataManagement sharedInstance] getListSongFilterByName:nil albumId:album.iAlbumId artistId:album.iAlbumArtistId genreId:album.iGenreId]];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            
            CreatePlaylistViewController *vc = [[CreatePlaylistViewController alloc] init];
            vc.listSong = listSong;
            [self.navigationController pushViewController:vc animated:YES];
        });
    }];
}

#pragma mark - UI

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

#pragma mark - Utils

- (void)setNumberOfSelect:(int)numberOfSelect
{
    self.title = [NSString stringWithFormat:@"Select (%d)",numberOfSelect];
    self.btnDone.enabled = (numberOfSelect > 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

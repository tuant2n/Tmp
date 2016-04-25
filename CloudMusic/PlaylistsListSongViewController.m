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

@interface PlaylistsListSongViewController () <TableHeaderViewDelegate,AddSongsViewControllerDelegate>
{
    NSArray *editMode, *normalMode;
}

@property (nonatomic, strong) PCSEQVisualizer *musicEq;
@property (nonatomic, strong) UIBarButtonItem *barMusicEq;

@property (nonatomic, strong) NSMutableArray *arrListData, *arrPlaylist;

@property (nonatomic, weak) IBOutlet UITableView *tblList;

@property (nonatomic, strong) UIButton *btnEdit, *btnClear, *btnDelete;
@property (nonatomic, strong) UIButton *btnDone, *btnAdd;

@property (nonatomic, strong) TableFooterView *footerView;
@property (nonatomic, strong) TableHeaderView *headerView;

@end

@implementation PlaylistsListSongViewController

- (NSMutableArray *)arrListData
{
    if (!_arrListData) {
        _arrListData = [[NSMutableArray alloc] init];
    }
    return _arrListData;
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
    NSOperationQueue *syncDataQueue = [[NSOperationQueue alloc] init];
    syncDataQueue.name = @"queue.get.listsong";
    
    [syncDataQueue addOperationWithBlock:^{
        [self.arrListData removeAllObjects];
        
        for (NSString *iSongId in self.arrPlaylist) {
            Item *song = [[DataManagement sharedInstance] getItemBySongId:iSongId];
            if (song) {
                [self.arrListData addObject:song];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tblList reloadData];
            [self configExternalView];
        });
    }];
}

- (void)setupUI
{
    self.title = self.currentPlaylist.sPlaylistName;
    self.navigationItem.rightBarButtonItem = self.barMusicEq;
    
    [Utils configNavigationController:self.navigationController];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    normalMode = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithCustomView:self.btnEdit],spaceItem,[[UIBarButtonItem alloc] initWithCustomView:self.btnClear],spaceItem,[[UIBarButtonItem alloc] initWithCustomView:self.btnDelete],nil];
    editMode = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithCustomView:self.btnDone],spaceItem,[[UIBarButtonItem alloc] initWithCustomView:self.btnAdd],nil];
    [self setToolbarItems:normalMode animated:NO];
    
    [Utils configTableView:self.tblList];
    [self setupEditView];
}

- (void)setupEditView
{
    [self setEnableAction:(self.arrPlaylist.count > 0)];
    [self setEnableEditView:!self.currentPlaylist.isSmartPlaylist.boolValue];
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
    return (SongsCell *)[tableView dequeueReusableCellWithIdentifier:@"SongsCellId" forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![cell isKindOfClass:[MainCell class]])
    {
        return;
    }
    
    id cellItem = self.arrListData[indexPath.row];
    
    MainCell *mainCell = (MainCell *)cell;
    [mainCell configWithoutMenu:cellItem];
    
    if (tableView.isEditing) {
        [mainCell setLineHidden:NO];
    }
    else {
        [mainCell setLineHidden:(indexPath.row == self.arrListData.count - 1)];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing) {
        return (UITableViewCellEditingStyleDelete);
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }
    
    [self.arrListData removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self.arrListData exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
}

#pragma mark - Method

- (void)touchEdit:(id)sender
{
    [self setToolbarItems:editMode animated:YES];
    [self showTableExtension:NO isAnimated:YES];
    
    [self.tblList setEditing:YES animated:YES];
}

- (void)touchDone:(id)sender
{
    [self setToolbarItems:normalMode animated:YES];
    [self showTableExtension:YES isAnimated:YES];
    
    [self.tblList setEditing:NO animated:YES];

    [self.currentPlaylist changePlaylist:self.arrListData];
    [[DataManagement sharedInstance] saveData:NO];
}

- (void)touchClear:(id)sender
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
         
         [self.arrListData removeAllObjects];
         [self.tblList reloadData];
         [self setEnableAction:NO];
         [self configExternalView];
         
         [self.currentPlaylist setPlaylist:[NSArray new]];
         self.currentPlaylist.fDuration = @(0);
         [self.currentPlaylist setArtwork:nil];

         [[DataManagement sharedInstance] saveData:NO];
     }];
}

- (void)touchDelete:(id)sender
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

- (void)touchAddSong:(id)sender
{
    AddSongsViewController *vc = [[AddSongsViewController alloc] init];
    vc.currentPlaylist = self.currentPlaylist;
    vc.currentListSongs = self.arrListData;
    vc.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}


- (void)getNewPlaylistItems:(NSArray *)newPlaylistItem
{
    [self.currentPlaylist changePlaylist:newPlaylistItem];
    
    [self.arrListData removeAllObjects];
    [self.arrListData addObjectsFromArray:newPlaylistItem];
    [self.tblList reloadData];
    [self configExternalView];
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
        [self showTableExtension:NO isAnimated:NO];
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
    [self showTableExtension:YES isAnimated:NO];
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
    [[DataManagement sharedInstance] doUtility:iType withData:self.arrListData fromNavigation:self.navigationController];
}

#pragma mark - ControlBar

- (UIButton *)btnEdit
{
    if (!_btnEdit) {
        _btnEdit = [Utils createBarButtonWithTitle:@"Edit" font:[UIFont fontWithName:@"HelveticaNeue" size:16.0] textColor:0x017ee6 position:UIControlContentHorizontalAlignmentLeft target:self action:@selector(touchEdit:)];
    }
    return _btnEdit;
}

- (UIButton *)btnDone
{
    if (!_btnDone) {
        _btnDone = [Utils createBarButtonWithTitle:@"Done" font:[UIFont fontWithName:@"HelveticaNeue" size:16.0] textColor:0x017ee6 position:UIControlContentHorizontalAlignmentLeft target:self action:@selector(touchDone:)];
    }
    return _btnDone;
}

- (UIButton *)btnClear
{
    if (!_btnClear) {
        _btnClear = [Utils createBarButtonWithTitle:@"Clear" font:[UIFont fontWithName:@"HelveticaNeue" size:16.0] textColor:0x017ee6 position:UIControlContentHorizontalAlignmentCenter target:self action:@selector(touchClear:)];
    }
    return _btnClear;
}

- (UIButton *)btnDelete
{
    if (!_btnDelete) {
        _btnDelete = [Utils createBarButtonWithTitle:@"Delete" font:[UIFont fontWithName:@"HelveticaNeue" size:16.0] textColor:0x017ee6 position:UIControlContentHorizontalAlignmentRight target:self action:@selector(touchDelete:)];
    }
    return _btnDelete;
}

- (UIButton *)btnAdd
{
    if (!_btnAdd) {
        _btnAdd = [Utils createBarButton:@"btnAddSongToPlaylist.png" position:UIControlContentHorizontalAlignmentRight target:self selector:@selector(touchAddSong:)];
    }
    return _btnAdd;
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
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound)
    {
        [self setEnableEditView:NO];
    }
    [self.musicEq stopEq:NO];
    
    [super viewWillDisappear:animated];
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
    [self.navigationController setToolbarHidden:!isEnable animated:NO];
}

- (void)showTableExtension:(BOOL)isShow isAnimated:(BOOL)isAnimated
{
    if (isAnimated) {
        [UIView beginAnimations:nil context:NULL];
    }
    
    if (isShow) {
        [self.tblList setTableHeaderView:self.headerView];
        [self.tblList setTableFooterView:self.footerView];
    }
    else {
        [self.tblList setTableHeaderView:[UIView new]];
        [self.tblList setTableFooterView:[UIView new]];
    }
    
    if (isAnimated) {
        [UIView commitAnimations];
        
        for (MainCell *cell in self.tblList.visibleCells)
        {
            if (![cell isKindOfClass:[MainCell class]]) {
                return;
            }
            
            if (isShow) {
                NSIndexPath *indexPath = [self.tblList indexPathForCell:cell];
                if (indexPath) {
                    [cell setLineHidden:(indexPath.row == self.arrListData.count - 1)];
                }
                else {
                    [cell setLineHidden:NO];
                }
            }
            else {
                [cell setLineHidden:NO];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

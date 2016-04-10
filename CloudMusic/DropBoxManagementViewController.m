//
//  DropBoxManagementViewController.m
//  CloudMusic
//
//  Created by TuanTN on 4/7/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "DropBoxManagementViewController.h"

#import "DropBoxObj.h"
#import "DropBoxFileCell.h"

#import "Utils.h"
#import "GlobalParameter.h"
#import "DataManagement.h"

#define extesions @[@"mp3", @"m4a", @"wma", @"wav", @"aac", @"ogg"]

@interface DropBoxManagementViewController () <DBRestClientDelegate>
{
    BOOL isSelectAll;
}

@property (nonatomic, strong) UIButton *btnLogout;
@property (nonatomic, strong) UIButton *btnSelect, *btnDownload;


@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic, weak) IBOutlet UIView *emptyView;
@property (nonatomic, weak) IBOutlet UITableView *tblList;

@property (nonatomic, strong) NSMutableArray *arrListData;
@property (nonatomic, strong) DBRestClient *restClient;

@end

@implementation DropBoxManagementViewController

- (NSMutableArray *)arrListData
{
    if (!_arrListData) {
        _arrListData = [[NSMutableArray alloc] init];
    }
    return  _arrListData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    
    [self setupTitle];
    [self getData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.restClient cancelAllRequests];
}

- (void)setupTitle
{
    NSString *sTitle = nil;
    
    if (self.item) {
        sTitle = self.item.filename;
    }
    else {
        sTitle = [[GlobalParameter sharedInstance] getDropBoxName];
    }
    
    if (!sTitle) {
        self.title = @"DropBox";
        [self.restClient loadAccountInfo];
    }
    else {
        self.title = sTitle;
    }
}

- (void)getData
{
    NSString *loadData = @"/";
    
    if (self.item) {
        loadData = self.item.path;
    }
    
    [self setShowLoading:YES];
    [self.restClient loadMetadata:loadData];
}

#pragma mark - DBRestClientDelegate Methods for LoadData

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
    [self.arrListData removeAllObjects];
    
    NSSortDescriptor *name = [NSSortDescriptor sortDescriptorWithKey:@"filename" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *type = [[NSSortDescriptor alloc] initWithKey:@"isDirectory" ascending:NO];
    NSArray *items = [metadata.contents sortedArrayUsingDescriptors:@[type,name]];
    
    for (DBMetadata *item in items)
    {
        DropBoxObj *obj = [[DropBoxObj alloc] initWithMetadata:item];
        if (obj) {
            [self.arrListData addObject:obj];
        }
    }
    
    [self setShowLoading:NO];
    [self setShowEmptyView:(self.arrListData.count <= 0)];
    [self.btnSelect setEnabled:(self.arrListData.count > 0)];
    
    [self.tblList reloadData];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    [self setShowLoading:NO];
    [self setShowEmptyView:YES];
    [self.tblList reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrListData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DropBoxFileCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DropBoxFileCell *cell = (DropBoxFileCell *)[tableView dequeueReusableCellWithIdentifier:@"DropBoxFileCellId" forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DropBoxObj *item = self.arrListData[indexPath.row];
    if (item.iType == kFileTypeFolder) {
        DropBoxManagementViewController *vc = [[DropBoxManagementViewController alloc] init];
        vc.item = item.currentItem;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        item.isSelected = !item.isSelected;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[DropBoxFileCell class]]) {
        DropBoxFileCell *dropBoxCell = (DropBoxFileCell *)cell;
        
        DropBoxObj *item = self.arrListData[indexPath.row];
        [dropBoxCell configWithItem:item];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([cell isKindOfClass:[DropBoxFileCell class]]) {
        DropBoxFileCell *dropBoxCell = (DropBoxFileCell *)cell;
        [dropBoxCell removeObserver];
    }
}

#pragma mark - Method

- (void)selectAll
{
}

- (void)download
{
    
}

#pragma mark - DBRestClientDelegate Methods for DownloadFile

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath contentType:(NSString *)contentType metadata:(DBMetadata *)metadata
{
    
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    
}

- (void)restClient:(DBRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath
{
    
}

#pragma mark - Log In/Out

- (void)login
{
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
}

- (void)logout
{
    if ([[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] unlinkAll];
    }
    
    [[GlobalParameter sharedInstance] clearDropBoxInfo];
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UI

- (UIButton *)btnLogout
{
    if (!_btnLogout) {
        _btnLogout = [Utils createBarButtonWithTitle:@"Log Out" font:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0] textColor:0xff0000 position:UIControlContentHorizontalAlignmentRight target:self action:@selector(logout)];
    }
    return _btnLogout;
}

- (UIButton *)btnDownload
{
    if (!_btnDownload) {
        _btnDownload = [Utils createBarButtonWithTitle:@"Download" font:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0] textColor:0x017ee6 position:UIControlContentHorizontalAlignmentRight target:self action:@selector(download)];
        [_btnDownload setFrame:CGRectMake(_btnDownload.frame.origin.x, _btnDownload.frame.origin.y, 100.0, _btnDownload.frame.size.height)];
    }
    return _btnDownload;
}

- (UIButton *)btnSelect
{
    if (!_btnSelect) {
        _btnSelect = [Utils createBarButtonWithTitle:@"Select All" font:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0] textColor:0x017ee6 position:UIControlContentHorizontalAlignmentLeft target:self action:@selector(selectAll)];
        [_btnSelect setFrame:CGRectMake(_btnSelect.frame.origin.x, _btnSelect.frame.origin.y, 100.0, _btnSelect.frame.size.height)];
    }
    return _btnSelect;
}

- (void)setupUI
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnLogout];
    
    if (!self.item) {
        self.navigationItem.leftBarButtonItem = [Utils customBackNavigationWithTarget:self selector:@selector(onBack)];
    }
    
    [Utils configNavigationController:self.navigationController];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    self.tblList.tableFooterView = [UIView new];
    self.tblList.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tblList registerNib:[UINib nibWithNibName:@"DropBoxFileCell" bundle:nil] forCellReuseIdentifier:@"DropBoxFileCellId"];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *toolbarItems = [NSMutableArray arrayWithObjects:[[UIBarButtonItem alloc] initWithCustomView:self.btnSelect],spaceItem,[[UIBarButtonItem alloc] initWithCustomView:self.btnDownload],nil];
    [self setToolbarItems:toolbarItems];
    
    self.btnDownload.enabled = NO;
    self.btnSelect.enabled = NO;
    
    [self.navigationController setToolbarHidden:NO animated:NO];
}

- (void)onBack
{
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Dropbox Methods

- (DBRestClient *)restClient
{
    if (!_restClient) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

#pragma mark - DBRestClientDelegate Methods for DBAccountInfo

- (void)restClient:(DBRestClient *)client loadedAccountInfo:(DBAccountInfo *)info
{
    [[GlobalParameter sharedInstance] setDropBoxName:[info displayName]];
    [[GlobalParameter sharedInstance] setDropBoxId:[info userId]];
    
    self.title = [info displayName];
}

#pragma mark - Utils

- (void)setShowLoading:(BOOL)isShow
{
    if (isShow) {
        [self.loadingView startAnimating];
        
        self.loadingView.hidden = NO;
        [self.view bringSubviewToFront:self.loadingView];
    }
    else {
        [self.loadingView stopAnimating];
        
        self.loadingView.hidden = YES;
        [self.view sendSubviewToBack:self.loadingView];
    }
}

- (void)setShowEmptyView:(BOOL)isShow
{
    if (isShow) {
        self.emptyView.hidden = NO;
        [self.view bringSubviewToFront:self.emptyView];
    }
    else {
        self.emptyView.hidden = YES;
        [self.view sendSubviewToBack:self.emptyView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

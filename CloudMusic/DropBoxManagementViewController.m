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

#import "LDProgressView.h"
#import "DLAVAlertView.h"
#import "MarqueeLabel.h"

#define extesions @[@"mp3", @"m4a", @"wma", @"wav", @"aac", @"ogg"]

@interface DropBoxManagementViewController () <DBRestClientDelegate,DropBoxFileCellDelegate>
{
    BOOL isSelectAll;
    
    int iCurrentDownload;
    DLAVAlertView *downloadView;
    DropBoxObj *currentItem;
}

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic, weak) IBOutlet UIView *emptyView;
@property (nonatomic, weak) IBOutlet UITableView *tblList;

@property (nonatomic, strong) UIButton *btnLogout;
@property (nonatomic, strong) UIButton *btnSelect, *btnDownload;

@property (nonatomic, strong) NSMutableArray *arrListData;
@property (nonatomic, strong) NSMutableArray *arrSelected;

@property (nonatomic, strong) DBRestClient *restClient;

@property (nonatomic, strong) LDProgressView *progressBar;
@property (nonatomic, strong) MarqueeLabel *lblCurrentDownload;
@property (nonatomic, strong) UILabel *lblProgress;

@end

@implementation DropBoxManagementViewController

- (NSMutableArray *)arrListData
{
    if (!_arrListData) {
        _arrListData = [[NSMutableArray alloc] init];
    }
    return  _arrListData;
}

- (NSMutableArray *)arrSelected
{
    if (!_arrSelected) {
        _arrSelected = [[NSMutableArray alloc] init];
    }
    return  _arrSelected;
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
        DropBoxObj *dropboxObj = [[DropBoxObj alloc] initWithMetadata:item];
        if (dropboxObj) {
            [self.arrListData addObject:dropboxObj];
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
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[DropBoxFileCell class]]) {
        DropBoxFileCell *dropBoxCell = (DropBoxFileCell *)cell;
        
        DropBoxObj *dropboxObj = self.arrListData[indexPath.row];
        [dropBoxCell configWithItem:dropboxObj];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([cell isKindOfClass:[DropBoxFileCell class]]) {
        DropBoxFileCell *dropBoxCell = (DropBoxFileCell *)cell;
        [dropBoxCell removeObserver];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DropBoxObj *dropboxObj = self.arrListData[indexPath.row];
    if (dropboxObj.iType == kFileTypeFolder) {
        DropBoxManagementViewController *vc = [[DropBoxManagementViewController alloc] init];
        vc.item = dropboxObj.metaData;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        dropboxObj.isSelected = !dropboxObj.isSelected;
        
        if (dropboxObj.isSelected) {
            [self.arrSelected addObject:dropboxObj];
        }
        else {
            [self.arrSelected removeObject:dropboxObj];
        }
        [self.btnDownload setEnabled:(self.arrSelected.count > 0)];
    }
}

- (void)didSelectItem:(DropBoxObj *)dropboxObj
{
    dropboxObj.isSelected = !dropboxObj.isSelected;
    
    if (dropboxObj.isSelected) {
        [self.arrSelected addObject:dropboxObj];
    }
    else {
        [self.arrSelected removeObject:dropboxObj];
    }
    [self.btnDownload setEnabled:(self.arrSelected.count > 0)];
}

#pragma mark - Method

- (void)selectAll
{
    isSelectAll = !isSelectAll;
    [self.btnSelect setTitle:(isSelectAll ? @"Deselect All" : @"Selec All") forState:UIControlStateNormal];
    
    for (DropBoxObj *item in self.arrListData) {
        item.isSelected = isSelectAll;
    }
    
    [self.arrSelected removeAllObjects];
    if (isSelectAll) {
        [self.arrSelected addObjectsFromArray:self.arrListData];
    }
}

- (void)download
{
    if (self.arrSelected.count <= 0) {
        return;
    }
    
    iCurrentDownload = 0;
    [self downloadItemAtIndex:iCurrentDownload];
    
    downloadView = [[DLAVAlertView alloc] initWithTitle:@"" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Cancel",nil];
    [downloadView setContentView:self.downloadContentView];
    [downloadView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex)
     {
         if (buttonIndex == 0)
         {
             [self.restClient cancelAllRequests];
             [self closeDownloadView];
         }
     }];
}

- (void)closeDownloadView
{
    if (currentItem) {
        [currentItem removeObserver:self forKeyPath:@"fProgress"];
        currentItem = nil;
    }
}

- (void)downloadItemAtIndex:(int)iIndex
{
    if (currentItem) {
        [currentItem removeObserver:self forKeyPath:@"fProgress"];
    }
    
    currentItem = self.arrSelected[iIndex];
    
    currentItem.fProgress = 0.0;
    currentItem.isDownloadSuccess = NO;
    
    [currentItem addObserver:self forKeyPath:@"fProgress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    self.lblCurrentDownload.text = currentItem.sFileName;
    self.lblProgress.text = [NSString stringWithFormat:@"%d/%d",iIndex + 1,(int)self.arrSelected.count];
    self.progressBar.progress = 0.0;
    
    [self.restClient loadFile:currentItem.metaData.path intoPath:currentItem.sDownloadPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (![object isKindOfClass:[DropBoxObj class]] && [keyPath isEqualToString:@"isSelected"]) {
        return;
    }
    
    if (![object isEqual:currentItem]) {
        return;
    }
    
    self.progressBar.progress = currentItem.fProgress;
    NSLog(@"%f",currentItem.fProgress);
}

- (void)finishSingleDownload
{
    iCurrentDownload++;
    
    if (iCurrentDownload <= self.arrSelected.count - 1) {
        [self downloadItemAtIndex:iCurrentDownload];
    }
    else {
        [self finishAllDownload];
    }
}

- (void)finishAllDownload
{
    if (downloadView) {
        [downloadView dismissWithClickedButtonIndex:1 animated:YES];
    }
    
    [self closeDownloadView];
    
    NSLog(@"FINISH ALL TASK!!!");
    
    NSPredicate *filterDownloadSuccess = [NSPredicate predicateWithFormat:@"isDownloadSuccess == YES"];
    NSArray *listDownloadSuccess = [self.arrSelected filteredArrayUsingPredicate:filterDownloadSuccess];
    
    for (DropBoxObj *item in listDownloadSuccess) {
        NSLog(@"%@",item.sDownloadPath);
    }
    
    /*
     
     http://stackoverflow.com/questions/14030746/ios-avfoundation-how-do-i-fetch-artwork-from-an-mp3-file
     
     if (item.isCloud) {
     FileInfo *fileInfo = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([FileInfo class]) inManagedObjectContext:backgroundContext];
     item.fileInfo = fileInfo;
     [fileInfo updateFileInfo:item.sAssetUrl];
     
     // Test
     fileInfo.sFolderName = @"Tuan 123";
     fileInfo.sKind = @"MP3";
     fileInfo.sSize = @"11.93 MB";
     fileInfo.sBitRate = @"320 KBps";
     
     item.sLyrics = @"Đêm lại về, đêm tối tăm đêm lạnh câm \nNhìn mưa hắt lên ô cửa sổ, cuốn theo bao nhiêu tiếng lòng \nAnh lại về, giăng kín bao nhiêu niền tin \nNgày anh mang theo tất cả ngọt ngào đến ai \nRồi từng chiều con tim yếu đuối bước qua những nỗi buồn \nTập quen đi qua lối cũ hằng ngày, tập quen khi không có anh nữa \nEm không trông, thật lòng không mong cho dù thấp thoáng thấy dáng ai \nMùi hương thân quen khi xưa hu hù hu hú hu";
     }
     */
}

#pragma mark - DBRestClientDelegate Methods for DownloadFile

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath contentType:(NSString *)contentType metadata:(DBMetadata *)metadata
{
    currentItem.isDownloadSuccess = YES;
    [self finishSingleDownload];
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    currentItem.isDownloadSuccess = NO;
    [self finishSingleDownload];
}

- (void)restClient:(DBRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath
{
    if (!currentItem) {
        return;
    }
    
    currentItem.fProgress = progress;
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
    
    [self.restClient cancelAllRequests];
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

#pragma mark - Download View

- (MarqueeLabel *)lblCurrentDownload
{
    if (!_lblCurrentDownload) {
        _lblCurrentDownload = [[MarqueeLabel alloc] init];
        _lblCurrentDownload.backgroundColor = [UIColor clearColor];
        _lblCurrentDownload.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0];
        _lblCurrentDownload.textAlignment = NSTextAlignmentCenter;
        _lblCurrentDownload.marqueeType = MLContinuous;
        _lblCurrentDownload.scrollDuration = 10.0f;
        _lblCurrentDownload.rate = 20.0f;
        _lblCurrentDownload.fadeLength = 3.0f;
        _lblCurrentDownload.trailingBuffer = 50.0f;
        _lblCurrentDownload.animationDelay = 1.0f;
    }
    return _lblCurrentDownload;
}

- (UILabel *)lblProgress
{
    if (!_lblProgress) {
        _lblProgress = [[UILabel alloc] init];
        _lblProgress.backgroundColor = [UIColor clearColor];
        _lblProgress.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
        _lblProgress.textAlignment = NSTextAlignmentCenter;
        _lblProgress.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _lblProgress;
}

- (LDProgressView *)progressBar
{
    if (!_progressBar) {
        _progressBar = [[LDProgressView alloc] init];
        _progressBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _progressBar.progress = 0.0;
        _progressBar.showText = @NO;
        _progressBar.animate = @YES;
        _progressBar.color = [Utils colorWithRGBHex:0x017ee6];
        _progressBar.background = [UIColor lightGrayColor];
        _progressBar.flat = @YES;
        _progressBar.borderRadius = @1;
        _progressBar.showBackgroundInnerShadow = @NO;
        _progressBar.animateDirection = LDAnimateDirectionForward;
    }
    return _progressBar;
}

- (UIView *)downloadContentView
{
    UIView *downloadContentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 80.0)];
    downloadContentView.backgroundColor = [UIColor clearColor];
    
    [self.lblCurrentDownload setFrame:CGRectMake(0.0, 10.0, 250.0, 30.0)];
    [downloadContentView addSubview:self.lblCurrentDownload];
    
    [self.progressBar setFrame:CGRectMake(0.0, self.lblCurrentDownload.frame.origin.y + self.lblCurrentDownload.frame.size.height + 5.0, 250.0, 3.0)];
    [downloadContentView addSubview:self.progressBar];
    
    [self.lblProgress setFrame:CGRectMake(0.0, self.progressBar.frame.origin.y + self.progressBar.frame.size.height + 5.0, 250.0, 30.0)];
    [downloadContentView addSubview:self.lblProgress];
    
    return downloadContentView;
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

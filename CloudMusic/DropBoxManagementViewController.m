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
#import "KGModal.h"
#import "MarqueeLabel.h"
#import "MBProgressHUD.h"
#import "UIAlertView+Blocks.h"

#define extesions @[@"mp3", @"m4a", @"wma", @"wav", @"aac", @"ogg"]

@interface DropBoxManagementViewController () <DBRestClientDelegate,DropBoxFileCellDelegate>
{
    BOOL isSelectAll;
    
    int iCurrentIndex;
    DropBoxObj *currentItem;
}

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingView;
@property (nonatomic, weak) IBOutlet UIView *emptyView;
@property (nonatomic, weak) IBOutlet UITableView *tblList;

@property (nonatomic, strong) UIButton *btnLogout;
@property (nonatomic, strong) UIButton *btnSelect, *btnDownload;

@property (nonatomic, strong) NSMutableArray *arrListData;
@property (nonatomic, strong) NSMutableArray *arrSelected, *arrDownloadSuccess;;

@property (nonatomic, strong) DBRestClient *restClient;

@property (nonatomic, strong) UIView *downloadView;
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

- (NSMutableArray *)arrDownloadSuccess
{
    if (!_arrDownloadSuccess) {
        _arrDownloadSuccess = [[NSMutableArray alloc] init];
    }
    return  _arrDownloadSuccess;
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
    
    NSPredicate *filterFile = [NSPredicate predicateWithFormat:@"isDirectory == NO"];
    NSArray *listFile = [self.arrListData filteredArrayUsingPredicate:filterFile];
    [self.btnSelect setEnabled:(listFile.count > 0)];
    
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
    [self changeSelect:isSelectAll];
}

- (void)changeSelect:(BOOL)isSelect
{
    [self.btnSelect setTitle:(isSelect ? @"Deselect All" : @"Selec All") forState:UIControlStateNormal];
    
    for (DropBoxObj *item in self.arrListData) {
        item.isSelected = isSelect;
    }
    
    [self.arrSelected removeAllObjects];
    if (isSelect) {
        [self.arrSelected addObjectsFromArray:self.arrListData];
    }
}

#pragma mark - DownloadFile

- (void)download
{
    [[KGModal sharedInstance] setCloseButtonType:KGModalCloseButtonTypeNone];
    [[KGModal sharedInstance] setModalBackgroundColor:[UIColor whiteColor]];
    [[KGModal sharedInstance] setShouldRotate:YES];
    [[KGModal sharedInstance] setTapOutsideToDismiss:NO];
    
    [[KGModal sharedInstance] showWithContentView:self.downloadView andAnimated:NO];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    iCurrentIndex = 0;
    [self downloadItemAtIndex:iCurrentIndex];
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

- (void)downloadSuccess
{
    AVAssetExportSession *exportSession = [self exportItem:currentItem];
    if (exportSession) {
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (exportSession.status == AVAssetExportSessionStatusCompleted)
                {
                    [[DataManagement sharedInstance] insertSong:currentItem];
                    [[DataManagement sharedInstance] saveData];
                }
                
                [self downloadNextItem];
            });
        }];
        [self getExportSessionProgress:exportSession];
    }
    else {
        [self downloadNextItem];
    }
}

- (void)downloadNextItem
{
    iCurrentIndex++;
    if (iCurrentIndex <= self.arrSelected.count - 1)
    {
        [self downloadItemAtIndex:iCurrentIndex];
    }
    else {
        [self finishAllDownload];
    }
}

- (void)finishAllDownload
{
    [self closeDownloadView];
}

#pragma mark - DBRestClientDelegate Methods for DownloadFile

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath contentType:(NSString *)contentType metadata:(DBMetadata *)metadata
{
    currentItem.isDownloadSuccess = YES;
    [self downloadSuccess];
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    if (error) {
        if (currentItem.isRetryOnce) {
            [self downloadNextItem];
        }
        else {
            currentItem.isRetryOnce = YES;
            [self downloadItemAtIndex:iCurrentIndex];
        }
    }
    else {
        [self downloadNextItem];
    }
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
    [UIAlertView showWithTitle:@"Are you sure you want to logout?"
                       message:nil
             cancelButtonTitle:@"OK"
             otherButtonTitles:@[@"Cancel"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
         if (buttonIndex != [alertView cancelButtonIndex]) {
             return;
         }
         
         if ([[DBSession sharedSession] isLinked]) {
             [[DBSession sharedSession] unlinkAll];
         }
         
         [self.restClient cancelAllRequests];
         [[GlobalParameter sharedInstance] clearDropBoxInfo];
         
         [self.navigationController setToolbarHidden:YES animated:NO];
         [self.navigationController popToRootViewControllerAnimated:YES];
     }];
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

#pragma mark - Export

- (AVAssetExportSession *)exportItem:(DropBoxObj *)item
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:item.sDownloadPath] options:nil];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
    exportSession.outputURL = [NSURL fileURLWithPath:item.sExportPath];
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.metadata = item.songMetaData;
    
    return exportSession;
}

#pragma mark - Download View

- (UIView *)downloadView
{
    if (!_downloadView) {
        _downloadView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 250.0, 130.0)];
        _downloadView.backgroundColor = [UIColor clearColor];
        
        self.progressBar = [[LDProgressView alloc] initWithFrame:CGRectMake(5.0, 15.0, 240.0, 5.0)];
        self.progressBar.progress = 0.0;
        self.progressBar.showText = @NO;
        self.progressBar.animate = @NO;
        self.progressBar.color = [Utils colorWithRGBHex:0x017ee6];
        self.progressBar.background = [UIColor lightGrayColor];
        self.progressBar.flat = @YES;
        self.progressBar.borderRadius = @1;
        self.progressBar.showBackgroundInnerShadow = @NO;
        self.progressBar.animateDirection = LDAnimateDirectionForward;
        [_downloadView addSubview:self.progressBar];
        
        self.lblCurrentDownload = [[MarqueeLabel alloc] initWithFrame:CGRectMake(5.0, self.progressBar.frame.origin.y + self.progressBar.frame.size.height, 240.0, 45.0)];
        self.lblCurrentDownload.backgroundColor = [UIColor clearColor];
        self.lblCurrentDownload.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0];
        self.lblCurrentDownload.textAlignment = NSTextAlignmentCenter;
        self.lblCurrentDownload.marqueeType = MLContinuous;
        self.lblCurrentDownload.scrollDuration = 10.0f;
        self.lblCurrentDownload.rate = 20.0f;
        self.lblCurrentDownload.fadeLength = 3.0f;
        self.lblCurrentDownload.trailingBuffer = 50.0f;
        self.lblCurrentDownload.animationDelay = 1.0f;
        [_downloadView addSubview:self.lblCurrentDownload];
        
        self.lblProgress = [[UILabel alloc] initWithFrame:CGRectMake(0.0, self.lblCurrentDownload.frame.origin.y + self.lblCurrentDownload.frame.size.height, 250.0, 25.0)];
        self.lblProgress.backgroundColor = [UIColor clearColor];
        self.lblProgress.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        self.lblProgress.textAlignment = NSTextAlignmentCenter;
        self.lblProgress.lineBreakMode = NSLineBreakByTruncatingTail;
        [_downloadView addSubview:self.lblProgress];
        
        UIButton *btnCancelDownload = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnCancelDownload addTarget:self action:@selector(cancelDownload) forControlEvents:UIControlEventTouchUpInside];
        [btnCancelDownload setFrame:CGRectMake(0.0, self.lblProgress.frame.origin.y + self.lblProgress.frame.size.height, 250.0, 40.0)];
        [btnCancelDownload setBackgroundColor:[UIColor clearColor]];
        
        [btnCancelDownload.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0]];
        [btnCancelDownload setTitle:@"Cancel" forState:UIControlStateNormal];
        
        [btnCancelDownload setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [btnCancelDownload setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [btnCancelDownload setTitleColor:[Utils colorWithRGBHex:0x017ee6] forState:UIControlStateNormal];
        
        [_downloadView addSubview:btnCancelDownload];
    }
    return _downloadView;
}

- (void)cancelDownload
{
    [self.restClient cancelAllRequests];
    [self closeDownloadView];
}

- (void)closeDownloadView
{
    if (currentItem) {
        [currentItem removeObserver:self forKeyPath:@"fProgress"];
    }
    
    iCurrentIndex = 0;
    currentItem = nil;
    
    self.progressBar.progress = 0.0;
    self.progressBar.animate = @NO;
    
    self.lblCurrentDownload.text = nil;
    self.lblProgress.text = nil;
    
    isSelectAll = NO;
    [self changeSelect:isSelectAll];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[KGModal sharedInstance] hideAnimated:NO];
}

- (void)setContentDownloadView:(DropBoxObj *)dropboxObj atIndex:(int)iIndex
{
    if (!_downloadView) {
        [self downloadView];
    }
    
    self.lblCurrentDownload.text = dropboxObj.sFileName;
    self.lblProgress.text = [NSString stringWithFormat:@"%d/%d",iIndex + 1,(int)self.arrSelected.count];
    
    self.progressBar.progress = 0.0;
    self.progressBar.animate = @YES;
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
    NSLog(@"PROGRESS DOWNLOAD: %f",currentItem.fProgress);
}

- (void)getExportSessionProgress:(AVAssetExportSession *)session
{
    NSArray *modes = [[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, UITrackingRunLoopMode, nil];
    [self performSelector:@selector(updateProgress:) withObject:session afterDelay:0.5 inModes:modes];
}

- (void)updateProgress:(AVAssetExportSession *)session
{
    if (session.status == AVAssetExportSessionStatusExporting) {
        NSLog(@"PROGRESS EXPORT: %f",session.progress);
        [self getExportSessionProgress:session];
    }
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

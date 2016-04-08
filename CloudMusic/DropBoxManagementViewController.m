//
//  DropBoxManagementViewController.m
//  CloudMusic
//
//  Created by TuanTN on 4/7/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "DropBoxManagementViewController.h"
#import <DropboxSDK/DropboxSDK.h>

#import "Utils.h"

@interface DropBoxManagementViewController () <DBRestClientDelegate>
{
    NSString *loadData;
}

@property (nonatomic, strong) UIBarButtonItem *btnLogout;
@property (nonatomic, weak) IBOutlet UITableView *tblList;

@property (nonatomic, strong) DBRestClient *restClient;

@end

@implementation DropBoxManagementViewController

- (UIBarButtonItem *)btnLogout
{
    if (!_btnLogout) {
        _btnLogout = [[UIBarButtonItem alloc] initWithCustomView:[Utils createBarButtonWithTitle:@"Log Out" font:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0] textColor:0xff0000 position:UIControlContentHorizontalAlignmentRight target:self action:@selector(logout)]];
    }
    return _btnLogout;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    [self getData];
}

- (void)setupUI
{
    self.title = @"Dropbox";
    self.navigationItem.rightBarButtonItem = self.btnLogout;
    [Utils configNavigationController:self.navigationController];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
}

- (void)getData
{
    loadData = @"/";
    [self fetchAllDropboxData];
    [self.restClient loadAccountInfo];
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

-  (void)fetchAllDropboxData
{
    [self.restClient loadMetadata:loadData];
}

#pragma mark - DBRestClientDelegate Methods for LoadData

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata
{
    for (int i = 0; i < [metadata.contents count]; i++) {
        DBMetadata *data = [metadata.contents objectAtIndex:i];
        
        if (!data.isDirectory) {
            [self.restClient loadSharableLinkForFile:data.path];
        }
        else {
            NSLog(@"%@",data.path);
        }
        
        
        /*
         BOOL thumbnailExists;
         long long totalBytes;
         NSDate* lastModifiedDate;
         NSDate *clientMtime; // file's mtime for display purposes only
         NSString* path;
         BOOL isDirectory;
         NSArray* contents;
         NSString* hash;
         NSString* humanReadableSize;
         NSString* root;
         NSString* icon;
         NSString* rev;
         long long revision; // Deprecated; will be removed in version 2. Use rev whenever possible
         BOOL isDeleted;
         
         NSString *filename;
         */
    }
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{

}

#pragma mark - DBRestClientDelegate Methods for DownloadFile

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath contentType:(NSString *)contentType metadata:(DBMetadata *)metadata
{
    
}

- (void)restClient:(DBRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath
{
    
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    
}

#pragma mark - DBRestClientDelegate Methods for DBAccountInfo

- (void)restClient:(DBRestClient *)client loadedAccountInfo:(DBAccountInfo *)info
{
    NSLog(@"UserID: %@ %@", [info displayName], [info userId]);
}

- (void)restClient:(DBRestClient *)client loadAccountInfoFailedWithError:(NSError *)error
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
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

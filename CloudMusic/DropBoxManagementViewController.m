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

@property (nonatomic, strong) UIBarButtonItem *btnLogout, *btnLogin;
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

- (UIBarButtonItem *)btnLogin
{
    if (!_btnLogin) {
        _btnLogin = [[UIBarButtonItem alloc] initWithCustomView:[Utils createBarButtonWithTitle:@"Log In" font:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0] textColor:0x007cf6 position:UIControlContentHorizontalAlignmentRight target:self action:@selector(login)]];
    }
    return _btnLogin;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    [self setupData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:NOTIFICATION_LOGIN_DROPBOX object:nil];
}

- (void)setupUI
{
    self.title = @"Dropbox";
    [Utils configNavigationController:self.navigationController];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
}

- (void)setupData
{
    loadData = @"";
    
    if ([[DBSession sharedSession] isLinked]) {
        [self configWhenLinked];
    }
    else {
        [self configWhenNotLinked];
    }
}

- (void)loginSuccess:(NSNotification *)notification
{
    BOOL isSuccess = [notification.object boolValue];
    
    if (isSuccess) {
        [self configWhenLinked];
    }
    else {
        [self configWhenNotLinked];
    }
}

- (void)configWhenLinked
{
    self.navigationItem.rightBarButtonItem = self.btnLogout;
    [self fetchAllDropboxData];
}

- (void)configWhenNotLinked
{
    self.navigationItem.rightBarButtonItem = self.btnLogin;
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

#pragma mark - DBRestClientDelegate Methods for GetLink

- (void)restClient:(DBRestClient*)restClient loadedSharableLink:(NSString*)link forFile:(NSString*)path
{
    
}

- (void)restClient:(DBRestClient*)restClient loadSharableLinkFailedWithError:(NSError*)error
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
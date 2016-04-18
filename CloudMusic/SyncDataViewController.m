//
//  SyncDataViewController.m
//  CloudMusic
//
//  Created by TuanTN on 4/18/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "SyncDataViewController.h"

#import "AppDelegate.h"

#import "GlobalParameter.h"
#import "DataManagement.h"

#import "Utils.h"

@interface SyncDataViewController ()

@end

@implementation SyncDataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [Utils colorWithRGBHex:0x006bd5];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[DataManagement sharedInstance] syncDataWithBlock:^(bool isSuccess) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate openMainView];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

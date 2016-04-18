//
//  AppDelegate.m
//  CloudMusic
//
//  Created by TuanTN on 3/6/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "AppDelegate.h"
#import <DropboxSDK/DropboxSDK.h>

#import "MainTabBarController.h"
#import "SyncDataViewController.h"

#import "Utils.h"
#import "GlobalParameter.h"

@interface AppDelegate () <DBSessionDelegate,DBNetworkRequestDelegate>
{
    UIBackgroundTaskIdentifier bgTask;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    long lastTimeAppSync = [[DataManagement sharedInstance] getLastTimeAppSync];
    long lastTimeDeviceSync = [[[MPMediaLibrary defaultMediaLibrary] lastModifiedDate] timeIntervalSince1970];
    
    if (lastTimeAppSync != lastTimeDeviceSync)
    {
        [self openSyncDataViewController];
    }
    else {
        [self openMainView];
    }
    
    NSString *dropBoxAppKey = @"7g8osl380bj7x9j";
    NSString *dropBoxAppSecret = @"dge3dlml97z3e34";
    NSString *root = kDBRootDropbox;
    
    DBSession *session = [[DBSession alloc] initWithAppKey:dropBoxAppKey appSecret:dropBoxAppSecret root:root];
    session.delegate = self;
    [DBSession setSharedSession:session];
    [DBRequest setNetworkRequestDelegate:self];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOGIN_DROPBOX object:nil];
        }
        return YES;
    }
    return NO;
}

#pragma mark - DBSessionDelegateMethods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId
{
    [[GlobalParameter sharedInstance] clearDropBoxInfo];
}

#pragma mark - DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted
{
    outstandingRequests++;
    if (outstandingRequests == 1) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)networkRequestStopped
{
    outstandingRequests--;
    if (outstandingRequests == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    bgTask = [application beginBackgroundTaskWithName:@"BackgroundTask" expirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - OpenView

- (void)openMainView
{
    self.window.rootViewController = [[MainTabBarController alloc] init];
}

- (void)openSyncDataViewController
{
    self.window.rootViewController = [[SyncDataViewController alloc] init];
}

@end

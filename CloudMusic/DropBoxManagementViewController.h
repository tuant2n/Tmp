//
//  DropBoxManagementViewController.h
//  CloudMusic
//
//  Created by TuanTN on 4/7/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <DropboxSDK/DropboxSDK.h>

@interface DropBoxManagementViewController : UIViewController

@property (nonatomic, strong) DBMetadata *item;

@end

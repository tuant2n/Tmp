//
//  PlayerViewController.m
//  CloudMusic
//
//  Created by TuanTN8 on 3/10/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "PlayerViewController.h"

#import "Utils.h"

static PlayerViewController *sharedInstance = nil;

@interface PlayerViewController ()

@property (nonatomic, strong) UIButton *btnClose;

@property (nonatomic, weak) IBOutlet UIView *vPlayer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *vPlayerHeight;

@property (nonatomic, weak) IBOutlet UIView *vControlPlayer, *vInfoPlayer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *vControlPlayerWidth, *vInfoPlayerWidth;

@end

@implementation PlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (sharedInstance) {
        [NSException raise:@"Error" format:@"Tried to create more than one instance"];
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

+ (PlayerViewController *)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[PlayerViewController alloc] initWithNibName:@"PlayerViewController" bundle:nil];
    });
    return sharedInstance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    [self configPlayerViewFrame];
}

#pragma mark - UI

- (void)setupUI
{
    self.title = @"1 of 1";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.btnClose];
}

- (UIButton *)btnClose
{
    if (!_btnClose) {
        _btnClose = [Utils createBarButton:@"btn_close_player" position:UIControlContentHorizontalAlignmentLeft target:self selector:@selector(closeView)];
    }
    return _btnClose;
}

- (void)configPlayerViewFrame
{
    if ([Utils isLandscapeDevice]) {
        [self.vPlayerHeight setConstant:90.0];
        [self.vInfoPlayerWidth setConstant:DEVICE_SIZE.height/2.0];
        [self.vControlPlayerWidth setConstant:DEVICE_SIZE.height/2.0];
    }
    else {
        [self.vPlayerHeight setConstant:180.0];
        [self.vInfoPlayerWidth setConstant:DEVICE_SIZE.width];
        [self.vControlPlayerWidth setConstant:DEVICE_SIZE.width];
    }
}

- (void)closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

//
//  PlaylistNameView.m
//  CloudMusic
//
//  Created by TuanTN8 on 4/20/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "PlaylistNameView.h"

#import "Utils.h"

@interface PlaylistNameView() <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *lblPlaylists, *lblNewPlaylists;
@property (nonatomic, weak) IBOutlet UITextField *tfPlaylistName;

@end

@implementation PlaylistNameView

- (void)awakeFromNib
{
    self.backgroundColor = [Utils colorWithRGBHex:0xf0f0f0];
    
    self.tfPlaylistName.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.tfPlaylistName.delegate = self;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *sTmp = [[textField text] stringByReplacingCharactersInRange:range withString:string];

    if ([self.delegate respondsToSelector:@selector(didEnterName:)]) {
        [self.delegate didEnterName:sTmp];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (NSString *)getPlaylistName
{
    return self.tfPlaylistName.text;
}

- (void)configWhenEmpty:(BOOL)isEmpty
{
    self.lblPlaylists.hidden = isEmpty;
}

- (void)closeKeyboard
{
    if ([self.tfPlaylistName isFirstResponder]) {
        [self.tfPlaylistName resignFirstResponder];
    }
}

@end

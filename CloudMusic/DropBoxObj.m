//
//  DropBoxObj.m
//  CloudMusic
//
//  Created by TuanTN on 4/9/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "DropBoxObj.h"

#import <DropboxSDK/DropboxSDK.h>
#import "Utils.h"

@implementation DropBoxObj

- (id)initWithMetadata:(DBMetadata *)metadata
{
    self = [self init];
    
    if (self)
    {
        _currentItem = metadata;

        _sFileName = _currentItem.filename;
        _isDirectory = _currentItem.isDirectory;
        
        if (!_isDirectory)
        {
            _sDesc = [NSString stringWithFormat:@"%@ %@",_currentItem.humanReadableSize,[Utils getDateStringFromDate:_currentItem.lastModifiedDate dateFormat:@"dd/MM/yyyy"]];
            
            _isDirectory = _currentItem.isDirectory;
            
            NSString *sExtension = [[_sFileName pathExtension] lowercaseString];
            if ([sExtension isEqualToString:@"mp3"]) {
                _iType = kFileTypeMP3;
            }
            else if ([sExtension isEqualToString:@"m4a"]) {
                _iType = kFileTypeM4A;
            }
            else if ([sExtension isEqualToString:@"wma"]) {
                _iType = kFileTypeWMA;
            }
            else if ([sExtension isEqualToString:@"wav"]) {
                _iType = kFileTypeWAV;
            }
            else if ([sExtension isEqualToString:@"aac"]) {
                _iType = kFileTypeAAC;
            }
            else if ([sExtension isEqualToString:@"ogg"]) {
                _iType = kFileTypeOGG;
            }
            else {
                return nil;
            }
        }
        else {
            _iType = kFileTypeFolder;
        }
        
        _isSelected = NO;
    }
    
    return self;
}

@end

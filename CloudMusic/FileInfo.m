//
//  FileInfo.m
//  CloudMusic
//
//  Created by TuanTN on 4/4/16.
//  Copyright © 2016 TuanTN. All rights reserved.
//

#import "FileInfo.h"

#import <DropboxSDK/DropboxSDK.h>

#import "Item.h"
#import "DropBoxObj.h"

@implementation FileInfo

- (void)updateFileInfo:(DropBoxObj *)item
{
    self.sFolderName = @"/";
    self.sFileName = [[item.sExportPath lastPathComponent] stringByDeletingPathExtension];
    
    self.sSize = item.metaData.humanReadableSize;
    self.lTimestamp = @(time(nil));
}

@end

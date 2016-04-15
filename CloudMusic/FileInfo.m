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

#import "Utils.h"

@implementation FileInfo

@synthesize sTimeStamp;

- (void)updateFileInfo:(DropBoxObj *)item
{
    self.sFileName = [[item.sExportPath lastPathComponent] stringByDeletingPathExtension];
    self.lTimestamp = @(time(nil));
    self.sSize = [Utils getFileSize:item.sExportPath];
}


- (NSString *)sTimeStamp
{
    if (!sTimeStamp) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self.lTimestamp longValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy, hh:mm a"];
        
        sTimeStamp = [dateFormatter stringFromDate:date];
    }
    return sTimeStamp;
}

@end

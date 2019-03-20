//
//  HYFileTool.m
//  HYDownLoader
//
//  Created by 许伟杰 on 2019/3/18.
//  Copyright © 2019 JackXu. All rights reserved.
//

#import "HYFileTool.h"

@implementation HYFileTool


+(BOOL)fileExists:(NSString *)filePath{
    if (filePath.length == 0) {
        
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+(long long)fileSize:(NSString *)filePath{
    
    if (![self fileExists:filePath]) {
        return 0;
    }
    
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    return [fileInfo[NSFileSize] longLongValue];
}

+(void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath{
    if (![self fileExists:fromPath]) {
        return;
    }
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
}

+(void)removeFile:(NSString*)filePath{
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

@end

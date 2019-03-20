//
//  HYFileTool.h
//  HYDownLoader
//
//  Created by 许伟杰 on 2019/3/18.
//  Copyright © 2019 JackXu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYFileTool : NSObject


/**
 判断文件是否存在

 @param filePath 文件路径
 @return 是否存在
 */
+(BOOL)fileExists:(NSString *)filePath;


/**
 获取文件大小

 @param filePath 文件路径
 @return 文件大小
 */
+(long long)fileSize:(NSString *)filePath;


/**
 移动文件到新的路径

 @param fromPath 文件的原路径
 @param toPath 文件的新路径
 */
+(void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath;


/**
 删除文件

 @param filePath 文件路径
 */
+(void)removeFile:(NSString*)filePath;

@end

NS_ASSUME_NONNULL_END

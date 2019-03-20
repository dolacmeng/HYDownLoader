//
//  HYDownLoader.h
//  HYDownLoader
//
//  Created by 许伟杰 on 2019/3/18.
//  Copyright © 2019 JackXu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,HYDownloadState){
    HYDownloadStatePause,
    HYDownloadStateDowning,
    HYDownloadStateSuccess,
    HYDownloadStateFail
};

typedef void(^DownLoadInfoType)(long long totalSize);
typedef void(^ProgressBlockType)(float progress);
typedef void(^SuccesswBlockType)(NSString *path);
typedef void(^FailBlockType)(void);
typedef void(^StateChangeBlockType)(HYDownloadState state);

NS_ASSUME_NONNULL_BEGIN

@interface HYDownLoader : NSObject


/**
 下载状态
 */
@property(nonatomic,assign,readonly) HYDownloadState state;

/**
 下载进度
 */
@property(nonatomic,assign,readonly) float progress;

/**
 下载信息回调
 */
@property(nonatomic,copy) DownLoadInfoType downLoadInfo;

/**
 下载状态改变回调
 */
@property(nonatomic,copy) StateChangeBlockType stateChangeInfo;

/**
 下载进度改变回调
 */
@property(nonatomic,copy) ProgressBlockType progressChange;

/**
 下载成功回调
 */
@property(nonatomic,copy) SuccesswBlockType successBlock;

/**
 下载失败回调
 */
@property(nonatomic,copy) FailBlockType failBlock;


/**
 下载文件

 @param url 下载文件的网络地址
 */
-(void)downLoader:(NSURL *)url;

/**
 下载文件

 @param url 下载文件的网络地址
 @param downLoadInfo 下载信息block
 @param progressBlock 下载进度block
 @param successBlock 下载成功block
 @param failedBlock 下载失败block
 */
-(void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoType)downLoadInfo progress:(ProgressBlockType)progressBlock success:(SuccesswBlockType)successBlock failed:(FailBlockType)failedBlock;


/**
 暂停当前任务
 */
-(void)pauseCurrentTask;


/**
 取消当前任务
 */
-(void)cancelCurrentTask;

/**
 取消并清除当前任务
 */
-(void)cancelAndClean;

@end

NS_ASSUME_NONNULL_END

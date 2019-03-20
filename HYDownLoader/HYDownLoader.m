//
//  HYDownLoader.m
//  HYDownLoader
//
//  Created by 许伟杰 on 2019/3/18.
//  Copyright © 2019 JackXu. All rights reserved.
//

#import "HYDownLoader.h"
#import "HYFileTool.h"

#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject
#define kTmpPath NSTemporaryDirectory()


@interface HYDownLoader()<NSURLSessionDataDelegate>{
    long long _tempSize;//已下载文件大小
    long long _totalSize;//文件总大小
}

@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,weak) NSURLSessionDataTask *dataTask;

/**
 下载文件完成后的路径
 */
@property (nonatomic,copy) NSString *downloadedPath;
/**
 下载文件时的路径
 */
@property (nonatomic,copy) NSString *downloadingPath;
/**
 写入文件的流
 */
@property (nonatomic,strong) NSOutputStream *outputStream;

@end

@implementation HYDownLoader

-(NSURLSession*)session{
    if (_session == nil) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

-(void)setState:(HYDownloadState)state{
    if (_state == state) {
        return;
    }
    _state = state;
    
    if (self.stateChangeInfo) {
        self.stateChangeInfo(_state);
    }
    if (state == HYDownloadStateSuccess && self.successBlock) {
        self.successBlock(_downloadedPath);
    }
    if (state == HYDownloadStateFail && self.failBlock) {
        self.failBlock();
    }
}

-(void)setProgress:(float)progress{
    _progress = progress;
    
    if (self.progressChange) {
        self.progressChange(progress);
    }
}

-(void)pauseCurrentTask{
    if (self.state == HYDownloadStateDowning) {
        [self.dataTask suspend];
        self.state = HYDownloadStatePause;
    }
}

-(void)cancelCurrentTask{
    [self.session invalidateAndCancel];
    self.session = nil;
    self.state = HYDownloadStatePause;
}

-(void)cancelAndClean{
    [self cancelCurrentTask];
    [HYFileTool removeFile:self.downloadingPath];
}

-(void)resumeCurrenttask{
    if (self.dataTask && self.state == HYDownloadStatePause) {
        [self.dataTask resume];
        self.state = HYDownloadStateDowning;
    }
}

-(void)downLoader:(NSURL *)url{

    //如果任务存在，当前只是暂停，则继续下载
    if ([url isEqual:self.dataTask.originalRequest.URL] && self.state == HYDownloadStatePause) {
        [self resumeCurrenttask];
        return;
    }
    
    //1.文件的存放
    //下载时存放到temp（此目录用于存放临时文件，app退出时会被清理）
    //下载完成后移动到cache（iTunes不会备份此目录，此目录下文件不会在app退出时删除）
    NSString *fileName = url.lastPathComponent;
    self.downloadedPath = [kCachePath stringByAppendingPathComponent:fileName];
    self.downloadingPath = [kTmpPath stringByAppendingPathComponent:fileName];
    
    //1.判断url地址对应的资源是否已下载完成
    //1.1如果已完成，则返回相关信息
    if([HYFileTool fileExists:self.downloadedPath]){
        NSLog(@"已下载完成(文件已存在)");
        self.state = HYDownloadStateSuccess;
        return;
    }
    
    [self downloadWithURL:url offset:0];

    
    //2.否则检查临时文件是否存在
    //2.1若存在，以当前已存在文件大小，作为开始字节请求资源。
    if ([HYFileTool fileExists:self.downloadingPath]) {
        //获取本地文件大小（已下载部分）
        _tempSize = [HYFileTool fileSize:self.downloadingPath];
        [self downloadWithURL:url offset:_tempSize];
        return;
    }
    
    // 本地大小 == 总大小 则移动到cache文件夹
    // 本地大小 > 总大小  则删除本地缓存，重新从0开始下载
    // 本地大小 < 总大小  从本地大小开始下载
    
    //2.2 不存在，则从0字节开始请求资源
    [self downloadWithURL:url offset:0];
    
}

-(void)downLoader:(NSURL *)url downLoadInfo:(DownLoadInfoType)downLoadInfo progress:(ProgressBlockType)progressBlock success:(SuccesswBlockType)successBlock failed:(FailBlockType)failedBlock{
    self.downLoadInfo = downLoadInfo;
    self.progressChange = progressBlock;
    self.successBlock = successBlock;
    self.failBlock  = failedBlock;
    [self downLoader:url];
}


#pragma mark - 协议
//接收到响应头
- (void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSHTTPURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler{
    NSLog(@"%@",response);
    
    
    _totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length > 0) {
        _totalSize = [[[contentRangeStr componentsSeparatedByString:@"/"] lastObject] longLongValue];
    }
    self.downLoadInfo(_totalSize);
    
    if (_tempSize == _totalSize) {
        //文件移动到完成文件夹
        NSLog(@"下载完成，移动文件到完成文件夹");
        [HYFileTool moveFile:_downloadingPath toPath:_downloadedPath];
        completionHandler(NSURLSessionResponseCancel);
        self.state = HYDownloadStateSuccess;
        return;
    }
    
    if (_tempSize > _totalSize) {
        //删除临时缓存
        [HYFileTool removeFile:self.downloadingPath];
        //重新下载
        [self downLoader:response.URL];
        //取消请求
        completionHandler(NSURLSessionResponseCancel);
    }
    
    //继续接受数据
    self.state = HYDownloadStateDowning;
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.downloadingPath append:YES];
    completionHandler(NSURLSessionResponseAllow);
}

//继续接收数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    _tempSize += data.length;
    self.progress = 1.0 * _tempSize / _totalSize;
    
    [self.outputStream write:data.bytes maxLength:data.length];
    NSLog(@"接受数据");
}

//请求结束
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"接收完成");
    if (error == nil) {
        [HYFileTool moveFile:self.downloadingPath toPath:self.downloadedPath];
        self.state = HYDownloadStateSuccess;
    }else{
        if(error.code == -999){
            NSLog(@"取消下载");
            self.state = HYDownloadStatePause;
        }else{
            NSLog(@"下载错误%@",error);
            self.state = HYDownloadStateFail;
        }
    }
    [self.outputStream close];
}





/**
 根据开始字节，请求资源

 @param url 下载url
 @param offset 开始字节
 */
- (void)downloadWithURL:(NSURL *)url offset:(long long)offset{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    self.dataTask = [self.session dataTaskWithRequest:request];
    [self resumeCurrenttask];
}



@end

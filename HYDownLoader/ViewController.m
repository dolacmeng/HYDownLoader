//
//  ViewController.m
//  HYDownLoader
//
//  Created by 许伟杰 on 2019/3/18.
//  Copyright © 2019 JackXu. All rights reserved.
//

#import "ViewController.h"
#import "HYDownLoader.h"

@interface ViewController ()

@property(nonatomic,strong) HYDownLoader *downloader;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(HYDownLoader*)downloader{
    if (!_downloader) {
        _downloader = [HYDownLoader new];
    }
    return _downloader;
}

- (IBAction)download:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://m801.music.126.net/20190319152941/202d62c88bb1d475ed36534917c1d993/jdyyaac/0509/0f52/030f/2cbf727932886fc4fd6c4e0d934ca7e0.m4a"];
    [self.downloader downLoader:url downLoadInfo:^(long long totalSize) {
        NSLog(@"totalSize:%lld",totalSize);
    } progress:^(float progress) {
        NSLog(@"progress:%f",progress);
    } success:^(NSString *path) {
        NSLog(@"success:%@",path);
    } failed:^{
        NSLog(@"fail");
    }];
}

- (IBAction)pause:(id)sender {
    [self.downloader pauseCurrentTask];
}

- (IBAction)cancel:(id)sender {
    [self.downloader cancelCurrentTask];
}

- (IBAction)cancelClean:(id)sender {
    [self.downloader cancelAndClean];
}

@end

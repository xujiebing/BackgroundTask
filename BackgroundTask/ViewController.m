//
//  ViewController.m
//  BackgroundTask
//
//  Created by 徐结兵 on 2019/4/1.
//  Copyright © 2019 一个叫DB的程序猿. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;    // 用来保存后台运行任务的标示符

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 进入前台监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    // 进入后台监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - 私有方法

- (void)p_becomeActive {
    [self p_removeBackgroundTask];
}

- (void)p_enterBackground {
    // 判断如果申请后台任务失败了, return
    if (self.backgroundTask == UIBackgroundTaskInvalid) {
        return;
    }
    // 后台申请20s时间处理上传事件，时间自定义，但是不能超过系统最长时间
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self p_removeBackgroundTask];
    });
    
}

// 移除任务
- (void)p_removeBackgroundTask {
    UIApplication *application = [UIApplication sharedApplication];
    if (_backgroundTask != UIBackgroundTaskInvalid) {
        [application endBackgroundTask:_backgroundTask];
        _backgroundTask = UIBackgroundTaskInvalid;
    }
}

#pragma mark - 懒加载方法

- (UIBackgroundTaskIdentifier)backgroundTask {
    if (!_backgroundTask) {
        _backgroundTask = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{
            // 超过系统规定的后台运行时间（10分钟）, 则暂停后台逻辑
            [UIApplication.sharedApplication endBackgroundTask:self->_backgroundTask];
            self->_backgroundTask = UIBackgroundTaskInvalid;
        }];
    }
    return _backgroundTask;
}

@end

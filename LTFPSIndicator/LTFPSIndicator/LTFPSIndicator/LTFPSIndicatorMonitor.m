//
//  LTFPSIndicatorMonitor.m
//  LTFPSIndicator
//
//  Created by 李腾 on 2017/7/24.
//  Copyright © 2017年 lt. All rights reserved.
//

#import "LTFPSIndicatorMonitor.h"
#import "LTFPSIndecatorView.h"

@interface LTFPSIndicatorMonitor()

@property (nonatomic, getter=isIndicatorPaused) BOOL indicatorPaused;

@property (nonatomic, getter=isIndicatorHidden) BOOL indicatorHidden;

@property (nonatomic, getter=isIndicatorStopped) BOOL indicatorStopped;

@property (nonatomic,strong) LTFPSIndecatorView *indecatorView;

@end

@implementation LTFPSIndicatorMonitor

+ (instancetype)sharedInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        instance =  [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self resigterNotification];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)resigterNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark - ************* public Method

- (void)startMonitoring {
    self.indicatorHidden = NO;
    self.indicatorPaused = NO;
    self.indicatorStopped = NO;
    
    [self startOrResumeMonitoring];
}

- (void)pauseMonitoring {
    self.indicatorPaused = YES;
    
    [self.indecatorView pauseMonitoring];
}

- (void)hideMonitoring {
    self.indicatorHidden = YES;
    
    [self.indecatorView hideMonitoring];
}

- (void)stopMonitoring {
    self.indicatorStopped = YES;
    
    [self.indecatorView stopMonitoring];
    [self.indecatorView removeFromSuperview];
    self.indecatorView = nil;
}


#pragma mark - Notifications & Observers

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (self.isIndicatorPaused) {
        return;
    }
    
    [self startOrResumeMonitoring];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    [self.indecatorView pauseMonitoring];
}

#pragma mark - ************* Monitoring

/**
 启动监听
 */
- (void)startOrResumeMonitoring {
    if (!_indecatorView) {
        [self setupPerformanceView];
    } else {
        [self.indecatorView resumeMonitoringAndShowMonitoringView:!self.isIndicatorHidden];
    }
}

- (void)setupPerformanceView
{
    if (self.isIndicatorStopped) {
        return;
    }
    
    [[UIApplication sharedApplication].delegate.window addSubview:self.indecatorView];
    [[UIApplication sharedApplication].delegate.window bringSubviewToFront:self.indecatorView];
    
    if (self.isIndicatorPaused) {
        [self.indecatorView pauseMonitoring];
    }
    if (self.isIndicatorHidden) {
        [self.indecatorView hideMonitoring];
    }
}

- (LTFPSIndecatorView *)indecatorView{
    if (!_indecatorView) {
        _indecatorView = [[LTFPSIndecatorView alloc] initWithFrame:CGRectMake(0, 200, 100, 50)];
    }
    return _indecatorView;
}


@end

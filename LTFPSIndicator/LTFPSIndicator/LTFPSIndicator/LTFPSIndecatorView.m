//
//  LTFPSIndecatorView.m
//  LTFPSIndicator
//
//  Created by 李腾 on 2017/7/24.
//  Copyright © 2017年 lt. All rights reserved.
//

#import "LTFPSIndecatorView.h"
#import "UIView+simpleFrame.h"
#import <mach/mach.h>
#import <QuartzCore/QuartzCore.h>

@interface LTFPSIndecatorView()

@property (nonatomic,strong) UILabel *lblFPS;

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic) CFTimeInterval screenUpdatesBeginTime;

@property (nonatomic) CFTimeInterval averageScreenUpdatesTime;

@property (nonatomic) int screenUpdatesCount;

@end

@implementation LTFPSIndecatorView

- (UILabel *)lblFPS
{
    if (!_lblFPS) {
        _lblFPS = [[UILabel alloc]initWithFrame:self.bounds];
        _lblFPS.numberOfLines = 3;
        [_lblFPS setTextAlignment:NSTextAlignmentCenter];
        [_lblFPS setTextColor:[UIColor whiteColor]];
        [_lblFPS setFont:[UIFont systemFontOfSize:12.f]];
    }
    return _lblFPS;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupWindowAndDefaultVariables];
        [self setupLabel];
        [self resumeMonitoringAndShowMonitoringView:YES];
        [self setupDisplayLink];
    }
    return self;
}


- (void)setupWindowAndDefaultVariables
{
    self.screenUpdatesCount = 0;
    self.screenUpdatesBeginTime = 0.0f;
    self.averageScreenUpdatesTime = 0.017f;
    
    UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewEvent:)];
    [self addGestureRecognizer:moveGesture];
    self.userInteractionEnabled = YES;
    [self setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5]];
}

- (void)setupLabel
{
    [self addSubview:self.lblFPS];
}

- (void)setupDisplayLink
{
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}


#pragma mark - ************* pan手势
- (void)moveViewEvent:(UIPanGestureRecognizer *)sender
{
    UIWindow *superView = [UIApplication sharedApplication].delegate.window;
    CGPoint position = [sender locationInView:superView];
    if(sender.state == UIGestureRecognizerStateBegan){
        self.alpha = 0.4;
    }else if(sender.state == UIGestureRecognizerStateChanged){
        self.center = position;
    }else if(sender.state == UIGestureRecognizerStateEnded){
        CGRect newFrame = CGRectMake(MIN(superView.width-self.width, MAX(0, self.x)),
                                     MIN(superView.height-self.height, MAX(0, self.y)),
                                     self.width,
                                     self.height);
        
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = newFrame;
            self.alpha = 1;
        }];
    }
}

#pragma mark - *************  Monitoring
- (void)displayLinkAction:(CADisplayLink *)displayLink
{
    if (self.screenUpdatesBeginTime == 0.0f) {
        self.screenUpdatesBeginTime = displayLink.timestamp;
    } else {
        self.screenUpdatesCount += 1;
        
        CFTimeInterval screenUpdatesTime = self.displayLink.timestamp - self.screenUpdatesBeginTime;
        
        if (screenUpdatesTime >= 1.0) {
            CFTimeInterval updatesOverSecond = screenUpdatesTime - 1.0f;
            int framesOverSecond = updatesOverSecond / self.averageScreenUpdatesTime;
            
            self.screenUpdatesCount -= framesOverSecond;
            if (self.screenUpdatesCount < 0) {
                self.screenUpdatesCount = 0;
            }
            
            [self updateData];
        }
    }
}

- (void)updateData
{
    int fps = self.screenUpdatesCount;
    float cpu = [self cpuUsage];
    
    self.screenUpdatesCount = 0;
    self.screenUpdatesBeginTime = 0.0f;
    
    [self reportFPS:fps CPU:cpu];
    [self updateMonitoringLabelWithFPS:fps CPU:cpu];
}

- (float)cpuUsage
{
    kern_return_t kern;
    
    thread_array_t threadList;
    mach_msg_type_number_t threadCount;
    
    thread_info_data_t threadInfo;
    mach_msg_type_number_t threadInfoCount;
    
    thread_basic_info_t threadBasicInfo;
    uint32_t threadStatistic = 0;
    
    kern = task_threads(mach_task_self(), &threadList, &threadCount);
    if (kern != KERN_SUCCESS) {
        return -1;
    }
    if (threadCount > 0) {
        threadStatistic += threadCount;
    }
    
    float totalUsageOfCPU = 0;
    
    for (int i = 0; i < threadCount; i++) {
        threadInfoCount = THREAD_INFO_MAX;
        kern = thread_info(threadList[i], THREAD_BASIC_INFO, (thread_info_t)threadInfo, &threadInfoCount);
        if (kern != KERN_SUCCESS) {
            return -1;
        }
        
        threadBasicInfo = (thread_basic_info_t)threadInfo;
        
        if (!(threadBasicInfo -> flags & TH_FLAGS_IDLE)) {
            totalUsageOfCPU = totalUsageOfCPU + threadBasicInfo -> cpu_usage / (float)TH_USAGE_SCALE * 100.0f;
        }
    }
    
    kern = vm_deallocate(mach_task_self(), (vm_offset_t)threadList, threadCount * sizeof(thread_t));
    
    return totalUsageOfCPU;
}


/**
 获取当前任务所占用的内存（单位：MB）

 @return str
 */
- (NSString *)useMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return @"TotalM:not found";
    }
    
    return [[NSString alloc]initWithFormat:@"TotalM:%0.2f M",taskInfo.resident_size / 1024.0 / 1024.0];
}

#pragma mark - Other Methods
- (void)reportFPS:(int)fpsValue CPU:(float)cpuValue
{
    [self.delegate monitorDidReportFPS:fpsValue CPU:cpuValue];
}

- (void)updateMonitoringLabelWithFPS:(int)fpsValue CPU:(float)cpuValue
{
    UIColor *fpsColor;
    if(fpsValue >= 55){
        fpsColor = [UIColor greenColor];
    }else if(fpsValue >= 45){
        fpsColor = [UIColor yellowColor];
    }else{
        fpsColor = [UIColor redColor];
    }
    
    NSString *fpsStr = [NSString stringWithFormat:@"%ld", (long)fpsValue];
    NSString *totalStr = [NSString stringWithFormat:@"FPS:%@\nCPU:%@%% \n%@",fpsStr,[NSString stringWithFormat:@"%.2f",cpuValue],[self useMemory]];
    NSRange range = [totalStr rangeOfString:fpsStr];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:totalStr];
    [attributedString addAttribute:NSForegroundColorAttributeName value:fpsColor range:range];
    
    [self.lblFPS setAttributedText:attributedString];
}

#pragma mark - ************* 挂起、重启、停止、隐藏 公共方法
- (void)pauseMonitoring
{
    [self.displayLink setPaused:YES];
    [self.lblFPS removeFromSuperview];
    self.lblFPS = nil;
}

- (void)resumeMonitoringAndShowMonitoringView:(BOOL)showView
{
    if (showView) {
        [self addSubview:self.lblFPS];
        [self.displayLink setPaused:NO];
    }
}

- (void)hideMonitoring {
    [self.lblFPS removeFromSuperview];
    self.lblFPS = nil;
}

- (void)stopMonitoring
{
    [self.displayLink invalidate];
    self.displayLink = nil;
    [self.lblFPS removeFromSuperview];
    self.lblFPS = nil;
}



@end
